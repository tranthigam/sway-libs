library;

use std::{
    bytes::Bytes,
    storage::{
        storable_slice::{
            clear_slice,
            get_slice,
            StorableSlice,
            store_slice,
        },
        storage_api::read,
    },
};
use string::String;

pub struct StorageString {}

impl StorableSlice<String> for StorageKey<StorageString> {
    /// Takes a `String` type and saves the underlying data in storage.
    ///
    /// ### Arguments
    ///
    /// * `string` - The string which will be stored.
    ///
    /// ### Number of Storage Accesses
    ///
    /// * Writes: `2`
    ///
    /// ### Examples
    ///
    /// ```sway
    /// storage {
    ///     stored_string: StorageString = StorageString {}
    /// }
    ///
    /// fn foo() {
    ///     let mut string = String::new();
    ///     string.push(5_u8);
    ///     string.push(7_u8);
    ///     string.push(9_u8);
    ///
    ///     storage.stored_string.store(string);
    /// }
    /// ```
    #[storage(read, write)]
    fn store(self, string: String) {
        store_slice(self.slot, string.as_raw_slice());
    }

    /// Constructs a `String` type from storage.
    ///
    /// ### Number of Storage Accesses
    ///
    /// * Reads: `2`
    ///
    /// ### Examples
    ///
    /// ```sway
    /// storage {
    ///     stored_string: StorageString = StorageString {}
    /// }
    ///
    /// fn foo() {
    ///     let mut string = String::new();
    ///     string.push(5_u8);
    ///     string.push(7_u8);
    ///     string.push(9_u8);
    ///
    ///     assert(storage.stored_string.load(key).is_none());
    ///     storage.stored_string.store(string);
    ///     let retrieved_string = storage.stored_string.load(key).unwrap();
    ///     assert(string == retrieved_string);
    /// }
    /// ```
    #[storage(read)]
    fn load(self) -> Option<String> {
        match get_slice(self.slot) {
            Option::Some(slice) => {
                Option::Some(String::from_raw_slice(slice))
            },
            Option::None => Option::None,
        }
    }

    /// Clears a stored `String` in storage.
    ///
    /// ### Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Clears: `2`
    ///
    /// ### Examples
    ///
    /// ```sway
    /// storage {
    ///     stored_string: StorageString = StorageString {}
    /// }
    ///
    /// fn foo() {
    ///     let mut string = String::new();
    ///     string.push(5_u8);
    ///     string.push(7_u8);
    ///     string.push(9_u8);
    ///     storage.stored_string.store(string);
    ///
    ///     assert(storage.stored_string.load(key).is_some());
    ///     let cleared = storage.stored_string.clear();
    ///     assert(cleared);
    ///     let retrieved_string = storage.stored_string.load(key);
    ///     assert(retrieved_string.is_none());
    /// }
    /// ```
    #[storage(read, write)]
    fn clear(self) -> bool {
        clear_slice(self.slot)
    }

    /// Returns the length of `String` in storage.
    ///
    /// ### Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// ### Examples
    ///
    /// ```sway
    /// storage {
    ///     stored_string: StorageString = StorageString {}
    /// }
    ///
    /// fn foo() {
    ///     let mut string = String::new();
    ///     string.push(5_u8);
    ///     string.push(7_u8);
    ///     string.push(9_u8);
    ///
    ///     assert(storage.stored_string.len() == 0)
    ///     storage.stored_string.store(string);
    ///     assert(storage.stored_string.len() == 3);
    /// }
    /// ```
    #[storage(read)]
    fn len(self) -> u64 {
        read::<u64>(self.slot, 0).unwrap_or(0)
    }
}