use dep::std;

global HASHES_MAX = 2;
global VOUCHES_MAX = 2;

fn check_no_repeats(hashes: [Field; VOUCHES_MAX], hash_count: u8) {
    for i in 0..VOUCHES_MAX {
        for j in i + 1..VOUCHES_MAX {
            if i as u8 < hash_count {
                constrain hashes[i] != hashes[j];
            }
        };
    };
}

fn contains<T>(arr: [T], elem: T) -> bool {
    let mut elem_found = false;
    for i in 0..std::array::len(arr) {
        if arr[i] == elem {
            elem_found = true;
        }
    };
    elem_found
}

fn check_owned_hashes_exist(
    all_hashes: [Field; HASHES_MAX],
    owned_hashes: [Field; VOUCHES_MAX],
    owned_vouch_count: u8
) {
    let mut all_exist = true;
    for i in 0..VOUCHES_MAX {
        if i as u8 < owned_vouch_count & !contains(all_hashes, owned_hashes[i]) {
            all_exist = false;
        }
    };
    constrain all_exist == true;
}

fn hash_vouches(
    recipient_id: Field,
    votes: [u32; VOUCHES_MAX],
    secrets: [Field; VOUCHES_MAX]
) -> [Field; VOUCHES_MAX] {
    let mut hashes = [0; VOUCHES_MAX];
    for i in 0..VOUCHES_MAX {
        let transcript = [recipient_id, votes[i] as Field, secrets[i]];
        hashes[i] = std::hash::pedersen(transcript)[0];
    };
    hashes
}

fn sum_votes(votes: [u32], vote_count: u8) -> u32 {
    let mut total = 0;
    for i in 0..std::array::len(votes) {
        if i as u8  < vote_count {
            total = total + votes[i];
        } 
    };
    total
}

fn main(
    all_hashes: pub [Field; HASHES_MAX],
    owned_recipient_id: Field,
    owned_votes: [u32; VOUCHES_MAX],
    owned_secrets: [Field; VOUCHES_MAX],
    owned_vouch_count: u8
) -> pub u32 {
    let owned_hashes = hash_vouches(
        owned_recipient_id,
        owned_votes,
        owned_secrets
    );
    check_no_repeats(owned_hashes, owned_vouch_count);
    check_owned_hashes_exist(all_hashes, owned_hashes, owned_vouch_count);
    sum_votes(owned_votes, owned_vouch_count)
}