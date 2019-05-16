pragma solidity >=0.4.25;

contract OpenMarket {
    struct Buyer { //구매자 정보
        address buyerAddress;
        bytes32 name;
        uint age;
        bytes32 home;
        uint post;
        uint phone;
    }

    struct Seller{ //판매자 정보
        address sellerAddress;
        bytes32 name;
        bytes32 home;
        uint post;
        uint phone;
    }

    struct Payment{ //결제 정보
        address sellerAddress;
        uint date;
    }

    //상품 ID에 해당하는 구매자, 판매자, 결제정보를 각각 Info에 저장
    mapping (uint => Buyer) public buyerInfo;
    mapping (uint => Seller) public sellerInfo;
    mapping (uint => Payment) public paymentInfo;
    mapping (address => uint) public balance;

    address public owner; //컨트랙트 소유자 계정
    address[10] public buyers; //구매자 목록
    address[10] public sellers; //판매자 목록
    address[10] public payments; //결제 목록

    event LogBuyProduct(address _buyer, uint _id); //상품 구입 시, 생기는 event
    event LogDeliveryProduct(address _seller, uint _id); //상품 배송 시, 생기는 event
    event LogPaymentProduct(address _seller, uint _id); //상품 구매확인 시, 생기는 event

    constructor() public {
        owner = msg.sender;
    }

    //상품 구입시, 금액이 소유자 계정으로 이동
    function buyProduct(uint _id, bytes32 _name, uint _age, bytes32 _home, uint _post, uint _phone) public payable {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        buyers[_id] = msg.sender;
        buyerInfo[_id] = Buyer(msg.sender, _name, _age, _home, _post, _phone);

        address(uint160(owner)).transfer(msg.value);
        emit LogBuyProduct(msg.sender, _id);
    }

    //상품 배송 시, 배송금액이 소유자 계정으로 전송 
    function deliveryProduct(uint _id, bytes32 _name, bytes32 _home, uint _post, uint _phone) public payable {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        sellers[_id] = msg.sender;
        sellerInfo[_id] = Seller(msg.sender, _name, _home, _post, _phone);

        address(uint160(owner)).transfer(msg.value);
        emit LogDeliveryProduct(msg.sender, _id);
    }

    //상품 결제 시, 소유자 계정의 금액이 판매자 계정으로 지급
    function payProduct(uint _id, uint _date) public payable {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        payments[_id] = msg.sender;
        paymentInfo[_id] = Payment(msg.sender, _date);
        balance[owner] -= msg.value;
        balance[msg.sender] += msg.value;
        emit LogPaymentProduct(msg.sender, _id);
    }

    //구매자 정보
    function getBuyerInfo(uint _id) public view returns (address, bytes32, uint, bytes32, uint, uint) {
        Buyer memory buyer = buyerInfo[_id];
        return (buyer.buyerAddress, buyer.name, buyer.age, buyer.home, buyer.post, buyer.phone);
    }

    //모든 구매자 정보
    function getAllBuyers() public view returns (address[10] memory) {
        return buyers;
    }

    //판매자 정보
    function getSellerInfo(uint _id) public view returns (address, bytes32, bytes32, uint, uint) {
        Seller memory seller = sellerInfo[_id];
        return (seller.sellerAddress, seller.name, seller.home, seller.post, seller.phone);
    }

    //모든 판매자 정보
    function getAllSellers() public view returns (address[10] memory) {
        return sellers;
    }

    //결제 정보
    function getPaymentInfo(uint _id) public view returns (address, uint) {
        Payment memory payment = paymentInfo[_id];
        return (payment.sellerAddress, payment.date);
    }

    //모든 결제 정보
    function getAllPayments() public view returns (address[10] memory) {
        return payments;
    }

}
