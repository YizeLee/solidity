//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;
//引用https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol 檢查合約
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC165{
   function supportsInterface(bytes4 interfaceId) external view returns(bool) ;
}

interface IERC721Metadata{
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function tokenURI(uint256 tokenId) external view returns(string memory);
}
interface IERC721{
    //event
    event Approval(address indexed owner, address indexed approver, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Transfer(address indexed from, address indexed to, uint256 tokenId);
    //Query
    function balanceOf(address owner) external view returns(uint256 balance);
    function ownerOf(uint256 tokenId) external view returns(address owner);
    //Approve
    function approve(address approve, uint256 tokenId) external; //授權單個NFT給授權者
    function getApproved(uint256 tokenId) external view returns(address operator); //查詢NFT授權給哪個第三方
    function setApprovalForAll(address operator, bool _approved) external; //設定第三者(整包NFT)的註銷與授權
    function isApprovedForAll(address owner, address operator) external view returns(bool _approved);//查詢第三方是否被授權
    //TransferFrom
    function transferFrom(address from, address to, uint256 tokenId) external; //轉NFT給別人
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    //Mint
    function mint(address to, uint256 tokenId) external;
    function safemint(address to, uint256 tokenId, bytes memory data) external;
    function safemint(address to, uint256 tokenId) external;
    //Burn
    function burn(uint256 tokenId) external;
}
contract ERC721 is IERC721, IERC721Metadata, IERC165{
    address _owner;
    string _name;
    string _symbol;
    mapping(address => uint256) _balances;
    mapping(uint256 => address) _owners;
    mapping(uint256=>address) _tokenApprovals;
    mapping(address=>mapping(address=>bool)) _operatorApprovals; //持有者=>授權者:是否授權
    mapping(uint256=>string)_tokenURIs;//每一個tokenID(NFT)對應到一個網站(URI)
    constructor(string memory name_, string memory symbol_){
        // _owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
    }
    // modifier checkOwner(){
    //     require(_owner == msg.sender,unicode"必須是owner");
    //     _;
    // }
    function supportsInterface(bytes4 interfaceId) public pure returns(bool){
        return interfaceId == type(IERC721).interfaceId||
               interfaceId == type(IERC721Metadata).interfaceId||
               interfaceId == type(IERC165).interfaceId;
    }
    function name() public view returns(string memory){
        return _name;
    }
    function symbol() public view returns(string memory){
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view returns(string memory){
        address owner = _owners[tokenId];
        require(owner!=address(0), unicode"NFT已被銷毀或尚未鑄造"); //tokenID address 不能為address(0)
        return _tokenURIs[tokenId];
    }
    function setTokenURI(uint256 tokenId, string memory URI) public{
        address owner = _owners[tokenId];
        require(owner!=address(0), unicode"NFT已被銷毀或尚未鑄造"); //tokenID address 不能為address(0)
        _tokenURIs[tokenId] = URI; //設定NFT為對應的URI
    }
    function mint(address to, uint256 tokenId) public{
        require( to!=address(0) ,unicode"address不能為address(0)");//檢查不能鑄造給address(0)
        address owner = _owners[tokenId];
        require(owner == address(0), unicode"tokenID(NFT)已經被鑄造了");//檢查tokenID(NFT)，要為銷毀or還未鑄造。
        _balances[to] += 1; //收款者: 增加一個NFT
        _owners[tokenId] = to;   //收款者: 取得NFT的持有權
        emit Transfer(address(0), to, tokenId); //觸發轉帳: (address(0), 收款者, NFT)
    }
    function safemint(address to, uint256 tokenId, bytes memory data) public{
        mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), unicode"沒有實作ERC721Reveiver"); //檢查地址是否為合約地址

    }
    function safemint(address to, uint256 tokenId) public{
        safemint(to, tokenId, "");
    }
    function burn(uint256 tokenId) public{
        address owner = _owners[tokenId];
        require(msg.sender == owner, unicode"NFT持有者才能銷毀"); //商業模式:NFT持有者才能燒毀
        _balances[owner] -= 1; //因為燒毀一個NFT，tokenID 持有者的總餘額少一個
        // owner = address(0) //移除NFT: 第一種寫法
        delete owner;         //移除NFT: 第二種寫法
        delete _tokenApprovals[tokenId]; //移除NFT授權
        emit Transfer(owner, address(0), tokenId); //觸發事件(持有者, address(0), NFT)
    }

    function balanceOf(address owner) public view returns(uint256){
        require( owner != address(0), unicode"address不能為address(0)");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns(address){
        address owner = _owners[tokenId];
        require( owner != address(0), unicode"NFT持有人不能為address(0)");
        return owner;
    }
    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId]; //確認tokenID的持有者
        require(owner != to ,unicode"持有者與授權者不能是同一人"); //檢查持有者與授權者不能是同一人，避免授權給自己的狀況
        //檢查呼叫者是否為持有者 或 是否為授權全部NFT的授權者
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender), unicode"呼叫者既不是持有者，也不是被授權全部NFT的授權者");
        _tokenApprovals[tokenId] = to; //授權NFT
        emit Approval(owner, to, tokenId); //因為有授權，所以觸發授權事件(持有者, 授受者, NFT)
    }
    
    function getApproved(uint256 tokenId) public view returns(address){
        address owner = _owners[tokenId]; //取得tokenId的持有者
        require(owner != address(0), unicode"NFT尚未被鑄造or已經被銷毀");
        return _tokenApprovals[tokenId]; //回傳授權者
    }
    function setApprovalForAll(address operator, bool _approved) public{
        require(msg.sender != operator,unicode"持有者(owner)與授權者不能為同一人"); 
        _operatorApprovals[msg.sender][operator] = _approved; //持有者=>授權者: 是否授權
        emit ApprovalForAll(msg.sender, operator, _approved); // (持有人，授權者，是否授權)事件
    }
    function isApprovedForAll(address owner, address operator) public view returns(bool){
        return _operatorApprovals[owner][operator];
    }
    
    function _transfer(address from, address to, uint256 tokenId) internal{
        address owner = _owners[tokenId];
        require(owner==from, unicode"持有者(owner)與輸入address(from)要同一人"); //檢查NFT持有者與輸入address(from)要同一人
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender) || getApproved(tokenId) == msg.sender, unicode"呼叫者必須是持有者或呼叫者必須被授權整個NFT或呼叫者必須被授權單一NFT");
        delete _tokenApprovals[tokenId]; //移除NFT的被授權者
        _balances[from] = _balances[from] - 1; // owner 餘額減少1個NFT
        _balances[to] = _balances[to] + 1;     // to 餘額多1個NFT
        _owners[tokenId] = to;                 // to 成為新的擁有者
        emit Transfer(from, to, tokenId);     //觸發授權事件
    }
    function transferFrom(address from, address to, uint256 tokenId) public{
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public{
        _safeTransfer(from, to, tokenId, data);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public{
        _safeTransfer(from, to, tokenId, "");
    }
    
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal{
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), unicode"沒有實作ERC721Reveiver");
    }

    //引用: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol 檢查合約
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) { //檢查是否為合約(addres.code.length)
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
