pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyLittleTiger is ERC721EnumerableUpgradeable {
    using Counters for Counters.Counter;
    using StringsUpgradeable for uint256;

    address[] public whiteList;
    mapping(address => bool) public isWhiteListed;
    bool public isTransferBlocked;

    address public masterAdmin;
    uint256 public assetLimit;
    string public baseURIextended;
    bool public uriSet;
    Counters.Counter public _tokenIdCounter;

    uint256 public unlocked;
    mapping(address => bool) public isMinted;

    modifier onlyMasterAdmin() {
        require(msg.sender == masterAdmin, "ContractError: CALLER_MUST_BE_MASTERADMIN");
        _;
    }

    modifier preMintChecker(address receiver) {
        require(uriSet == true, "ContractError: INVALID_BASE_URI_SET");
        require(isWhiteListed[msg.sender] == true, "ContractError: ACCESS_DENIED");
        require(msg.sender == masterAdmin || msg.sender == receiver, "ContractError: CALLER_IS_NOT_RECEIVER");
        require(totalSupply() + 1 <= assetLimit, "ContractError: ASSET_LIMIT");
        require(isMinted[receiver] == false, "ContractError: IS_MINTED");
        _;
    }

    modifier transferBlockChecker(address from) {
        require(isTransferBlocked == false || from == masterAdmin, "ContractError: TRANSFER_BLOCKED");
        _;
    }

    modifier lock() {
        require(unlocked == 1, "E10");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 assetLimit_
    ) external initializer {
        __ERC721_init(name_, symbol_);
        masterAdmin = msg.sender;
        whiteList.push(msg.sender);
        isWhiteListed[msg.sender] = true;
        assetLimit = assetLimit_;
        uriSet = false;
        isTransferBlocked = false;
    }

    // Metadata set
    function setBaseURI(string memory baseURI_) external onlyMasterAdmin {
        uriSet = true;
        baseURIextended = baseURI_;
    }

    // Emergency function
    function setMasterAdmin(address masterAdmin_) external onlyMasterAdmin {
        masterAdmin = masterAdmin_;
    }

    function setAssetLimit(uint256 assetLimit_) external onlyMasterAdmin {
        assetLimit = assetLimit_;
    }

    function setTransferBlock(bool isTransferBlocked_) external onlyMasterAdmin {
        isTransferBlocked = isTransferBlocked_;
    }

    function setInitialReEntrancyValue() external onlyMasterAdmin {
        unlocked = 1;
    }

    function setIsMinted(address user, bool value) external onlyMasterAdmin {
        isMinted[user] = value;
    }

    // Set address to whitelist
    function setWhiteList(address user) external onlyMasterAdmin {
        require(isWhiteListed[user] == false, "ContractError: ALREADY_LISTED");
        whiteList.push(user);
        isWhiteListed[user] = true;
    }

    // Internal mint function
    function _singleMint(address receiver) internal {
        uint256 id = _tokenIdCounter.current();
        if (id == 0) {
            _tokenIdCounter.increment();
            id = _tokenIdCounter.current();
        }

        _safeMint(receiver, id);
        _tokenIdCounter.increment();
    }

    /// @notice ?????? ????????? ???????????? ??????
    /// @dev singleMint??? ???????????? Minting??? ???, ????????? ?????? ???????????? ????????? ????????? ?????? ????????? whiteList??? ???????????? ????????? ??????.
    /// @param receiver: ????????? NFT??? ????????? ??????
    function singleMint(address receiver) external preMintChecker(receiver) lock {
        _singleMint(receiver);
        isMinted[receiver] = true;

        // ????????? ???????????? ??????, ?????????????????? ????????? ???????????? ??????.
        if (msg.sender != masterAdmin) {
            // ???????????????????????? ????????? ??????
            address[] memory whiteListLocal = whiteList;
            uint256 len = whiteListLocal.length;
            for (uint256 i = 0; i < len; i += 1) {
                if (whiteList[i] == receiver) {
                    whiteList[i] = whiteList[len - 1]; // i ?????? index??? ????????? index??? data??? ?????? (i?????? ??????)
                    whiteList.pop(); // ????????? index data ?????? (i ?????? index??? ?????? ????????? data)
                    break;
                }
            }
            isWhiteListed[receiver] = false;
        }
    }

    /// @notice ????????? ???????????? ?????? ??????
    /// @dev preMintChecker ??????????????? ????????????, ????????? ???????????? ???????????? ??????(???????????????, ?????? ?????? ??? SingleMint??? ???????????? ????????????.)
    /// @param receiver: ????????? NFT??? ????????? ??????
    /// @param mintNum: receive?????? ????????? ??????
    function adminMint(address receiver, uint256 mintNum) external onlyMasterAdmin {
        for (uint256 i = 0; i < mintNum; i++) {
            _singleMint(receiver);
        }
    }

    // View function
    function supportsInterface(bytes4 interfaceId) public view override(ERC721EnumerableUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    // internal function
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURIextended;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // ???????????? Transfer ?????? - ????????? ?????? Transfer ?????? ??????
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override transferBlockChecker(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override transferBlockChecker(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override transferBlockChecker(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
