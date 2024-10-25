import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Option "mo:base/Option";

actor {
    type Contact = {
        id : Nat;
        name : Text;
        email : Text;
        phone : Text;
        address : Text;
        groups : [Text];
    };

    private var nextId : Nat = 0;
    private var contacts = HashMap.HashMap<Nat, Contact>(0, Nat.equal, Hash.hash);

    public func addContact(name : Text, email : Text, phone : Text, address : Text, groups : [Text]) : async Nat {
        let id = nextId;
        let newContact : Contact = {
            id;
            name;
            email;
            phone;
            address;
            groups;
        };
        contacts.put(id, newContact);
        nextId += 1;
        id;
    };

    public query func getContact(id : Nat) : async ?Contact {
        contacts.get(id);
    };

    public func updateContact(id : Nat, name : ?Text, email : ?Text, phone : ?Text, address : ?Text, groups : ?[Text]) : async Bool {
        switch (contacts.get(id)) {
            case (null) { false };
            case (?existingContact) {
                let updatedContact : Contact = {
                    id = existingContact.id;
                    name = Option.get(name, existingContact.name);
                    email = Option.get(email, existingContact.email);
                    phone = Option.get(phone, existingContact.phone);
                    address = Option.get(address, existingContact.address);
                    groups = Option.get(groups, existingContact.groups);
                };
                contacts.put(id, updatedContact);
                true;
            };
        };
    };

    public func deleteContact(id : Nat) : async Bool {
        switch (contacts.remove(id)) {
            case (null) { false };
            case (?_) { true };
        };
    };

    public query func getAllContacts() : async [Contact] {
        Iter.toArray(contacts.vals());
    };

    public query func getContactsByGroup(group : Text) : async [Contact] {
        Array.filter<Contact>(
            Iter.toArray(contacts.vals()),
            func(contact : Contact) : Bool {
                Array.find<Text>(contact.groups, func(g : Text) : Bool { g == group }) != null;
            },
        );
    };

    public func addContactToGroup(id : Nat, group : Text) : async Bool {
        switch (contacts.get(id)) {
            case (null) { false };
            case (?contact) {
                if (Array.find<Text>(contact.groups, func(g : Text) : Bool { g == group }) == null) {
                    let updatedGroups = Array.append<Text>(contact.groups, [group]);
                    let updatedContact : Contact = {
                        id = contact.id;
                        name = contact.name;
                        email = contact.email;
                        phone = contact.phone;
                        address = contact.address;
                        groups = updatedGroups;
                    };
                    contacts.put(id, updatedContact);
                    true;
                } else {
                    false // Contact already in the group
                };
            };
        };
    };

    public func removeContactFromGroup(id : Nat, group : Text) : async Bool {
        switch (contacts.get(id)) {
            case (null) { false };
            case (?contact) {
                let updatedGroups = Array.filter<Text>(contact.groups, func(g : Text) : Bool { g != group });
                if (contact.groups.size() != updatedGroups.size()) {
                    let updatedContact : Contact = {
                        id = contact.id;
                        name = contact.name;
                        email = contact.email;
                        phone = contact.phone;
                        address = contact.address;
                        groups = updatedGroups;
                    };
                    contacts.put(id, updatedContact);
                    true;
                } else {
                    false // Contact was not in the group
                };
            };
        };
    };
};
