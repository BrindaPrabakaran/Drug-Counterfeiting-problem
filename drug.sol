// SPDX-License-Identifier: MIT
pragma solidity^0.8.17;

contract Drugs{
    enum OrganisationRole{
        Manufacturer,
        Distributor,
        Retailer,
        Customer
    }
    // Company Structure
    struct Company{
        string companyID;
        string name;
        string location;
        address admin;
        OrganisationRole organisationRole;
        uint8 hierarchyKey;
    }
    // Drug Structure
    struct Drug{
        string productID;
        string name;
        string manufacturer;
        string manufacturingDate;
        string expiryDate;
        string owner;
        string[] shipment;
        string[] history;
    }
    // Purchase Order Structure
    struct PurchaseOrder{
        string poID;
        string drugNmae;
        uint256 quantity;
        string buyer;
        string seller;
    }
    // Shipment Structure
    struct Shipment{
        string shipmentID;
        string creator;
        string[] assets;
        string transporter;
        string status;
    }

    mapping(string => Company) companies; // Mapping of Companies
    mapping(string => Drug) drugs; // Mapping of Drugs
    mapping(string => PurchaseOrder) purchaceOrders; // Mapping of PO
    mapping(string => Shipment) shipments; // Mapping of Shipments
    
    // Modifier to check if company is already registered 
    modifier notAlreadyRegistered(string memory _company){
        require(companies[_company].admin == address(0),
        "Company is already registered"
        );
        _;
    }

    // Modifier to check is company is already registered
    modifier alreadyRegistered(string memory _company){
        require(companies[_company].admin != address(0),
        "Company is not registered"
        );
        _;
    }

    // Modifier to check if the company is only a Manufacturer
    modifier onlyManufacturer (string memory _company){
        require(companies[_company].organisationRole == OrganisationRole.Manufacturer,
        "Company is not a Manufacturer"
        );
        _;
    }

    // Modifier to check if the company is only a Retailer
    modifier onlyRetailer (string memory _company){
        require(companies[_company].organisationRole == OrganisationRole.Retailer,
        "Company is not a Retailer"
        );
        _;
    }

    // Function to register a Company 
    function registerCompany(string memory _companyCRN,string memory _companyName, string memory _location, OrganisationRole _role)
    public notAlreadyRegistered(_companyCRN) returns (Company memory){
        companies[_companyCRN].companyID = _companyCRN;
        companies[_companyCRN].name = _companyName;
        companies[_companyCRN].location = _location;
        companies[_companyCRN].admin = msg.sender;

        if (_role == OrganisationRole.Manufacturer){      
            companies[_companyCRN].organisationRole = _role;  
            companies[_companyCRN].hierarchyKey = 1;
        } else if (_role == OrganisationRole.Distributor){
            companies[_companyCRN].organisationRole = _role;
            companies[_companyCRN].hierarchyKey = 2;
        } else if (_role == OrganisationRole.Retailer){
            companies[_companyCRN].organisationRole = _role;
            companies[_companyCRN].hierarchyKey = 3;
        } else{
            companies[_companyCRN].organisationRole = _role;
            companies[_companyCRN].hierarchyKey = 0;
        }
        return companies[_companyCRN];
       
    }

    // Function to view Registered Company
    function getRegisteredCompany(string memory _companyCRN) public view returns (Company memory){
        return companies[_companyCRN];
    }

    // Function to Add Drug
    function addDrug(string memory _drugName, string memory _serialNumber, string memory _manufacturingDate, string memory _expiryDAte,
    string memory companyCRN)public alreadyRegistered(_companyCRN) onlyManufacturer(_companyCRN){

        string memory _productID = string(abi.encodePacked(_drugName, ":", _serialNumber));

        drugs[_productID].productId = _productID;
        drugs[_productID].name = _drugName;
        drugs[_productID].manufacturer = _companyCRN;
        drugs[_productID].manufacturingDate = _manufacturingDate;
        drugs[_productID].expiryDate = _expiryDate;
        drugs[_productID].owner = _companyCRN;
        drugs[_productID].shipment = new string[](0);
        drugs[_productID].history = new string[](0);
        drugs[_productID].histoy.push("Drug added by Manufacturer");
    }

    // Function to view Registered Drugs
    function getRegisteredDrug(string memory _serialNumber, string memory _drugName) public view returns(Drug memory){

        string memory _productID = string(abi.encodePacked(_drugName, ":", _serialNumber));

        return drugs[_productID];
    }

    function createPO(string memory _buyerCRN,string memory _sellerCRN,string memory _drugName,uint256 _quantity)public
    alreadyRegistered(_buyerCRN) alreadyRegistered(_sellerCRN){

        string memory _poID = string(abi.encodePacked(_buyerCRN, ":", _drugName));

        purchaseOrders[_poID].poID = _poID;
        purchaseOrders[_poID].drugName = _drugName;
        purchaseOrders[_poID].buyer = _buyerCRN;
        purchaseOrders[_poID].quantity = _quantity;
        purchaseOrders[_poID].seller = companies[_sellerCRN].companyID;
    }

     function getRegisteredPO(string memory _buyerCRN, string memory _drugName) public view returns (PurchaseOrder memory) {

        string memory _poID = string(abi.encodePacked(_buyerCRN, ":", _drugName));

        return purchaseOrders[_poID];
    }

}



