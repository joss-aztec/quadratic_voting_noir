use dep::std;

global MAX_RECIPIENTS = 2;

fn check_squared_votes_sum(token_count: u32, votes: [u32; MAX_RECIPIENTS]) {
    let mut token_count_spent: u32 = 0;
    for i in 0..MAX_RECIPIENTS {
        let vote = votes[i];
        token_count_spent = token_count_spent + (vote * vote);
    };
    constrain token_count_spent <= token_count;
}

fn check_no_repeats(recipient_ids: [Field; MAX_RECIPIENTS]) {
    for i in 0..MAX_RECIPIENTS {
        for j in i + 1..MAX_RECIPIENTS {
            constrain recipient_ids[i] != recipient_ids[j];
        };
    };
}

fn hash_vouches(
    recipient_ids: [Field; MAX_RECIPIENTS],
    votes: [u32; MAX_RECIPIENTS],
    secrets: [Field; MAX_RECIPIENTS]
) -> [Field; MAX_RECIPIENTS] {
    let mut hashes = [0; MAX_RECIPIENTS];
    for i in 0..MAX_RECIPIENTS {
        let transcript = [recipient_ids[i], votes[i] as Field, secrets[i]];
        hashes[i] = std::hash::pedersen(transcript)[0];
    };
    hashes
}

fn main(
    token_count: pub u32,
    recipient_ids: [Field; MAX_RECIPIENTS],
    votes: [u32; MAX_RECIPIENTS],
    secrets: [Field; MAX_RECIPIENTS]
) -> pub [Field; MAX_RECIPIENTS] {
    check_squared_votes_sum(token_count, votes);
    check_no_repeats(recipient_ids);
    hash_vouches(recipient_ids, votes, secrets)
}