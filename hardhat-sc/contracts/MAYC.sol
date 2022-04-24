// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Bayc.sol";
import "./Bacc.sol";

contract MutantApeYachtClub is ERC721Enumerable, Ownable, ReentrancyGuard {
    // TODO: Not clear
    // Provenance hash for all mutants (Minted, Mutated Ape, MEGA)
    string public constant MAYC_PROVENANCE =
        "ca7151cc436da0dc3a3d662694f8c9da5ae39a7355fabaafc00e6aa580927175";

    // IDs 0 - 9999: Minted Mutants
    // IDs 10000 - 29999: Mutated Apes
    // IDs 30000 - 3007: MEGA Mutants
    uint8 private constant NUM_MUTANT_TYPES = 2;
    uint256 private constant MEGA_MUTATION_TYPE = 69;
    uint256 public constant NUM_MEGA_MUTANTS = 8;
    uint16 private constant MAX_MEGA_MUTATION_ID = 30007;
    uint256 public constant SERUM_MUTATION_OFFSET = 10000;

    uint256 public constant PS_MAX_MUTANT_PURCHASE = 20;
    // Max supply of Minted Mutants
    uint256 public constant PS_MAX_MUTANTS = 10000;
    // Public sale final price - 0.01 ETH
    uint256 public constant PS_MUTANT_ENDING_PRICE = 10000000000000000; // 0.01 ETH

    // Public sale starting price - mutable, in case we need to pause
    // and restart the sale
    uint256 public publicSaleMutantStartingPrice;

    // Supply of Minted Mutants (not Mutated Apes)
    uint256 public numMutantsMinted;

    // Public sale params
    uint256 public publicSaleDuration;
    uint256 public publicSaleStartTime;

    // Sale switches
    bool public publicSaleActive;
    bool public serumMutationActive;

    // Starting index block for the entire collection
    uint256 public collectionStartingIndexBlock;
    // Starting index for Minted Mutants
    uint256 public mintedMutantsStartingIndex;
    // Starting index for MEGA Mutants
    uint256 public megaMutantsStartingIndex;

    uint16 private currentMegaMutationId = 30000;
    mapping(uint256 => uint256) private megaMutationIdsByApe;

    string private baseURI;

    // State variables can be marked immutable which causes them to be read-only, but assignable in the constructor

    // The difference is that constant variables can never be changed after compilation, while immutable variables can be set within the constructor.

    Bayc private immutable bayc;
    Bacc private immutable bacc;

    event MutantPublicSaleStart(
        uint256 indexed _saleDuration,
        uint256 indexed _saleStartTime
    );

    event MutantPublicSalePaused(
        uint256 indexed _currentPrice,
        uint256 indexed _timeElapsed
    );
    event StartingIndicesSet(
        uint256 indexed _mintedMutantsStartingIndex,
        uint256 indexed _megaMutantsStartingIndex
    );

    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }

    modifier startingIndicesNotSet() {
        require(
            mintedMutantsStartingIndex == 0,
            "Minted Mutants starting index is already set"
        );
        require(
            megaMutantsStartingIndex == 0,
            "Mega Mutants starting index is already set"
        );
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address baycAddress,
        address baccAddress
    ) ERC721(name, symbol) {
        bayc = Bayc(baycAddress);
        bacc = Bacc(baccAddress);
    }

    function startPublicSale(uint256 saleDuration, uint256 saleStartPrice)
        external
        onlyOwner
    {
        require(!publicSaleActive, "Public sale has already begun");
        publicSaleDuration = saleDuration;
        publicSaleMutantStartingPrice = saleStartPrice;
        publicSaleStartTime = block.timestamp;
        publicSaleActive = true;
        emit MutantPublicSaleStart(saleDuration, publicSaleStartTime);
    }

    function getElapsedSaleTime() internal view returns (uint256) {
        return
            publicSaleStartTime > 0 ? block.timestamp - publicSaleStartTime : 0;
    }

    function getMintPrice() public view whenPublicSaleActive returns (uint256) {
        uint256 elapsed = getElapsedSaleTime();
        if (elapsed >= publicSaleDuration) {
            return PS_MUTANT_ENDING_PRICE;
        } else {
            uint256 currentPrice = ((publicSaleDuration - elapsed) *
                publicSaleMutantStartingPrice) / publicSaleDuration;
            return
                currentPrice > PS_MUTANT_ENDING_PRICE
                    ? currentPrice
                    : PS_MUTANT_ENDING_PRICE;
        }
    }

    function pausePublicSale() external onlyOwner whenPublicSaleActive {
        uint256 currentSalePrice = getMintPrice();
        publicSaleActive = false;
        emit MutantPublicSalePaused(currentSalePrice, getElapsedSaleTime());
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(owner()), balance);
    }

    function mintMutants(uint256 numMutants)
        external
        payable
        whenPublicSaleActive
        nonReentrant
    {
        require(
            numMutantsMinted + numMutants <= PS_MAX_MUTANTS,
            "Minting would exceed max supply"
        );
        require(numMutants > 0, "Must mint at least one mutant");
        require(
            numMutants <= PS_MAX_MUTANT_PURCHASE,
            "Requested number exceeds maximum"
        );

        uint256 costToMint = getMintPrice() * numMutants;
        require(costToMint <= msg.value, "Ether value sent is not correct");

        if (mintedMutantsStartingIndex == 0) {
            collectionStartingIndexBlock = block.number;
        }

        for (uint256 i = 0; i < numMutants; i++) {
            uint256 mintIndex = numMutantsMinted;
            if (numMutantsMinted < PS_MAX_MUTANTS) {
                numMutantsMinted++;
                _safeMint(msg.sender, mintIndex);
            }
        }

        if (msg.value > costToMint) {
            Address.sendValue(payable(msg.sender), msg.value - costToMint);
        }
    }

    function getMutantId(uint256 serumType, uint256 apeId)
        internal
        pure
        returns (uint256)
    {
        require(
            serumType != MEGA_MUTATION_TYPE,
            "Mega mutant ID can't be calculated"
        );
        return (apeId * NUM_MUTANT_TYPES) + serumType + SERUM_MUTATION_OFFSET;
    }

    function mutateApeWithSerum(uint256 serumTypeId, uint256 apeId)
        external
        nonReentrant
    {
        require(serumMutationActive, "Serum Mutation is not active");
        require(
            bayc.ownerOf(apeId) == msg.sender,
            "Must own the ape you're attempting to mutate"
        );
        require(
            bacc.balanceOf(msg.sender, serumTypeId) > 0,
            "Must own at least one of this serum type to mutate"
        );

        uint256 mutantId;

        if (serumTypeId == MEGA_MUTATION_TYPE) {
            require(
                currentMegaMutationId <= MAX_MEGA_MUTATION_ID,
                "Would exceed supply of serum-mutatable MEGA MUTANTS"
            );
            require(
                megaMutationIdsByApe[apeId] == 0,
                "Ape already mutated with MEGA MUTATION SERUM"
            );

            mutantId = currentMegaMutationId;
            megaMutationIdsByApe[apeId] = mutantId;
            currentMegaMutationId++;
        } else {
            mutantId = getMutantId(serumTypeId, apeId);
            require(
                !_exists(mutantId),
                "Ape already mutated with this type of serum"
            );
        }

        bacc.burnSerumForAddress(serumTypeId, msg.sender);
        _safeMint(msg.sender, mutantId);
    }
}
