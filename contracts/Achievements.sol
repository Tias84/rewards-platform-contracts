// SPDX-License-Identifier: MIT
// Questa è la licenza del software (MIT)
pragma solidity ^0.8.20;
// Questa è la versione di Solidity utilizzata (0.8.20)

// Importazione delle librerie necessarie da OpenZeppelin, un framework per contratti intelligenti sicuri
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// Definizione di una costante MAX_UINT che rappresenta il massimo valore possibile per un uint256 meno uno
uint256 constant MAX_UINT = type(uint256).max - 1;

// Definizione del contratto "Achievements", che eredita da ERC1155, AccessControl e ERC1155Supply
contract Achievements is ERC1155, AccessControl, ERC1155Supply {
    // Utilizzo della libreria EnumerableSet per le operazioni con i set di indirizzi
    using EnumerableSet for EnumerableSet.AddressSet;

    // Definizione di costanti pubbliche per i ruoli e gli achievement
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public constant AVVALER = 0;
    uint256 public constant TRAILBLAZER = 1;

    // Mappatura che associa ad ogni achievement un set di indirizzi che lo possiedono
    mapping(uint256 => EnumerableSet.AddressSet) private _owners;

    // Set di indirizzi autorizzati a creare nuovi achievement
    EnumerableSet.AddressSet private _allowedAddresses;

    // Costruttore del contratto
    constructor() ERC1155("QmcGqgnQUMT5GGMEBYoGrdhNZN181AcERTgZi6YP3mWQnc") {
        // Assegnazione dei ruoli di amministratore e minter all'indirizzo che ha creato il contratto
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        // Creazione iniziale di alcuni achievement
        _mint(msg.sender, AVVALER, 10, "");
        _mint(msg.sender, TRAILBLAZER, 0, "");
    }

    // Funzione per creare nuovi achievement
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        // Verifica che l'indirizzo sia autorizzato a creare nuovi achievement
        require(
            _allowedAddresses.contains(account),
            "Address not allowed to mint"
        );

        // Creazione dell'achievement
        _mint(account, id, amount, data);
        // Aggiunta dell'indirizzo al set di proprietari dell'achievement
        _owners[id].add(account);
    }

    // Funzione per creare un batch di nuovi achievement
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        // Creazione del batch di achievement
        _mintBatch(to, ids, amounts, data);

        // Aggiunta dell'indirizzo al set di proprietari di ogni achievement creato
        for (uint256 i = 0; i < ids.length; i++) {
            _owners[ids[i]].add(to);
        }
    }

    // Queste funzioni sono override richiesti da Solidity

    // Funzione per aggiornare i dati degli achievement
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        // Chiamata alla funzione _update delle classi base
        super._update(from, to, ids, values);
    }

    // Funzione per verificare il supporto di un'interfaccia
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        // Chiamata alla funzione supportsInterface delle classi base
        return super.supportsInterface(interfaceId);
    }

    //* New functions
    // Funzione per trasferire in modo sicuro un achievement da un indirizzo ad un altro
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        // Verifica che l'indirizzo destinatario sia autorizzato a ricevere achievement
        require(
            _allowedAddresses.contains(to),
            "Address not allowed to receive tokens"
        );

        // Chiamata alla funzione safeTransferFrom della classe base
        super.safeTransferFrom(from, to, id, amount, data);

        // Se l'indirizzo destinatario non possiede ancora l'achievement, viene aggiunto al set di proprietari
        if (!_owners[id].contains(to)) {
            _owners[id].add(to);
        }

        // Se l'indirizzo mittente non possiede più l'achievement, viene rimosso dal set di proprietari
        if (balanceOf(from, id) == 0) {
            _owners[id].remove(from);
        }
    }

    // Funzione per ottenere il numero di proprietari unici di un achievement
    function uniqueOwnersCount(uint256 id) public view returns (uint256) {
        return _owners[id].length();
    }

    // Funzione per aggiungere un indirizzo alla lista di indirizzi autorizzati a creare e ricevere achievement
    function addAllowedAddress(
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _allowedAddresses.add(account);
    }

    // Funzione per rimuovere un indirizzo dalla lista di indirizzi autorizzati a creare e ricevere achievement
    function removeAllowedAddress(
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _allowedAddresses.remove(account);
    }

    // Funzione per ottenere la lista di proprietari di un achievement
    function getOwners(uint256 id) public view returns (address[] memory) {
        // Recupero del set di proprietari dell'achievement
        EnumerableSet.AddressSet storage ownersSet = _owners[id];
        // Creazione di un array di indirizzi della stessa lunghezza del set di proprietari
        address[] memory owners = new address[](ownersSet.length());
        // Riempimento dell'array con gli indirizzi dei proprietari
        for (uint i = 0; i < ownersSet.length(); i++) {
            owners[i] = ownersSet.at(i);
        }
        // Restituzione dell'array di proprietari
        return owners;
    }

    // Funzione per ottenere la lista di indirizzi autorizzati a creare e ricevere achievement
    function getAllowedAddresses() public view returns (address[] memory) {
        // Creazione di un array di indirizzi della stessa lunghezza del set di indirizzi autorizzati
        address[] memory allowedAddresses = new address[](
            _allowedAddresses.length()
        );
        // Riempimento dell'array con gli indirizzi autorizzati
        for (uint i = 0; i < _allowedAddresses.length(); i++) {
            allowedAddresses[i] = _allowedAddresses.at(i);
        }
        // Restituzione dell'array di indirizzi autorizzati
        return allowedAddresses;
    }

    // Funzione per verificare se un indirizzo è in _allowedAddresses
    function isAllowedAddress(address account) public view returns (bool) {
        // Verifica se l'indirizzo è contenuto nel set di indirizzi autorizzati
        return _allowedAddresses.contains(account);
    }
}
