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

    struct Payment{ //구매확정 정보
        address buyerAddress;
        uint date;
        bytes32 review;
    }

    struct Cancel{ //구매취소 정보
        address buyerAddress;
        uint date;
        bytes32 reason;
    }

    struct doPay{
        address managerAddress;
        uint date;
    }

    struct doCancel{ //환불 정보
        address managerAddress;
        uint date;
    }

    //상품 ID에 해당하는 구매자, 판매자, 결제정보를 각각 Info에 저장
    mapping (uint => Buyer) public buyerInfo;
    mapping (uint => Seller) public sellerInfo;
    mapping (uint => Payment) public decidePaymentInfo;
    mapping (uint => Cancel) public decideCancelInfo;
    mapping (uint => doPay) public doPaymentInfo;
    mapping (uint => doCancel) public doCancelInfo;

    address public owner; //컨트랙트 소유자 계정
    address[10] public buyers; //구매자 목록
    address[10] public sellers; //판매자 목록
    address[10] public decidePayments; //구매확정 목록
    address[10] public decideCancels; //구매취소 목록
    address[10] public doPayments; //정산목록
    address[10] public doCancels; //환불목록

    event LogBuyProduct(address _buyer, uint _id); //상품 구입 시, 생기는 event
    event LogDeliveryProduct(address _seller, uint _id); //상품 배송 시, 생기는 event
    event LogDecidePayment(address _buyer, uint _id); //상품 구매확정 시, 생기는 event
    event LogDecideCancel(address _buyer, uint _id); //상품 구매취소 시, 생기는 event
    event LogPaymentProduct(address _manager, uint _id); //상품 금액정산 시, 생기는 event
    event LogCancelProduct(address _manager, uint _id); //상품 금액환불 시, 생기는 event

    constructor() public {
        owner = msg.sender;
        //msg.sender는 현재 사용하는 계정으로 컨트랙트의 소유자나 함수를 불러오는 것으로 주소형, default는 첫 번째 계정
    }

    //상품 구입시, 금액이 소유자 계정으로 이동
    //매개변수로 계정, 이름, 나이, 집주소, 우편번호, 핸드폰번호를 이용
    function buyProduct(uint _id, bytes32 _name, uint _age, bytes32 _home, uint _post, uint _phone) public payable {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        buyers[_id] = msg.sender; //현재 상품을 구매하는 계정을 구매자배열에 저장하는데, 매물의 id를 인덱스값으로 저장
        buyerInfo[_id] = Buyer(msg.sender, _name, _age, _home, _post, _phone); //구매자의 정보를 저장

        address(uint160(owner)).transfer(msg.value); //함수에서 넘겨받은 값을 msg.value로 해서 이더를 전달
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

    //구매확정
    function decidePayProduct(uint _id, uint _date, bytes32 _review) public {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        decidePayments[_id] = msg.sender;
        decidePaymentInfo[_id] = Payment(msg.sender, _date, _review);
        //require(msg.sender == address(this), "to tranfer ether from contract to address");
        emit LogDecidePayment(msg.sender, _id);
    }

    //금액정산
    function doPayProduct(uint _id, uint _date) public payable {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        doPayments[_id] = msg.sender;
        doPaymentInfo[_id] = doPay(msg.sender, _date);
        address(uint160(sellers[_id])).transfer(msg.value);
        emit LogPaymentProduct(msg.sender, _id);
    }

    //구매취소
    function decideCancelProduct(uint _id, uint _date, bytes32 _reason) public {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        decideCancels[_id] = msg.sender;
        decideCancelInfo[_id] = Cancel(msg.sender, _date, _reason);
        emit LogDecideCancel(msg.sender, _id);
    }

    //금액환불
    function doCancelProduct(uint _id, uint _date) public payable {
        require(_id >= 0 && _id <= 9, "the input shoud be included in the _id's ranges");
        doCancels[_id] = msg.sender;
        doCancelInfo[_id] = doCancel(msg.sender, _date);
        address(uint160(buyers[_id])).transfer(msg.value);
        emit LogCancelProduct(msg.sender, _id);
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

    //구매확정 정보
    function getPaymentInfo(uint _id) public view returns (address, uint, bytes32) {
        Payment memory payment = decidePaymentInfo[_id];
        return (payment.buyerAddress, payment.date, payment.review);
    }

    //모든 구매확정 정보
    function getAllPayments() public view returns (address[10] memory) {
        return decidePayments;
    }

    //구매취소 정보
    function getCancelInfo(uint _id) public view returns (address, uint, bytes32) {
        Cancel memory cancel = decideCancelInfo[_id];
        return (cancel.buyerAddress, cancel.date, cancel.reason);
    }

    //모든 구매취소 정보
    function getAllCancels() public view returns (address[10] memory) {
        return decideCancels;
    }

    //정산정보
    function getdoPaymentInfo(uint _id) public view returns (address, uint) {
        doPay memory dopay = doPaymentInfo[_id];
        return (dopay.managerAddress, dopay.date);
    }

    //모든 정산 정보
    function getAlldoPayments() public view returns (address[10] memory) {
        return doPayments;
    }
    
    //환불정보
    function getdoCancelInfo(uint _id) public view returns (address, uint) {
        doCancel memory docancel = doCancelInfo[_id];
        return (docancel.managerAddress, docancel.date);
    }

    //모든 환불 정보
    function getAlldoCancels() public view returns (address[10] memory) {
        return doCancels;
    }
}
