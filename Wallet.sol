pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract Wallet {
    
    struct Car {
        string mark;
        string model;
        uint horsePower;
        uint price;    
    }
    Car[] cars;

    mapping(uint=>uint) carToOwner;

    constructor() public {
        // check that contract's public key is set
        require(tvm.pubkey() != 0, 101);
        // Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    function createToken(string mark, string model, uint horsePower) public {
        tvm.accept();
        for (uint i = 0;i<cars.length;i++){
            require((cars[i].mark != mark)&&(cars[i].model != model),101,"Car was added");
        }
        tvm.accept();
        cars.push(Car(mark, model, horsePower, 0));
        uint key = cars.length-1;
        carToOwner[key] = msg.pubkey();
    }
   
    function putUpForSale(uint key, uint price) public getTokenOwner(key){
    cars[key].price = price;         
    }

    modifier getTokenOwner(uint key) {
        require(msg.pubkey() == carToOwner[key], 101);
        tvm.accept();
        _;
    }

    function getCars() public view returns(Car[]){
        return cars;
    }
    function getCar(uint key) public view returns(Car){
        return cars[key];
    }

    modifier checkOwnerAndAccept {        
        require(msg.pubkey() == tvm.pubkey(), 100);		
		tvm.accept();
		_;
	}
    
    function sendTransactionInCommision(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept {
         
        dest.transfer(value, bounce, 0);
    }
    function sendTransactionOutComission(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept {
         
        dest.transfer(value, bounce, 1);
    }
    function sendFullAndDestroy(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept {
         
        dest.transfer(value, bounce, 160);
    }
}