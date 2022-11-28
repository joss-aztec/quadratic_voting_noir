use dep::std;

global CANDIDATE_COUNT = 10; // Number of candidates on ballot card

fn check_within_budget(token_budget: u32, votes: [u32]) {
    let mut tokens_spent: u32 = 0;
    for i in 0..std::array::len(votes) {
        let vote = votes[i];
        tokens_spent = tokens_spent + (vote * vote);
    };
    constrain tokens_spent <= token_budget;
}

fn calculate_ballot_commitment(
    secret: Field,
    votes: [u32; CANDIDATE_COUNT]
) -> Field {
    let mut transcript = [0; CANDIDATE_COUNT + 1];
    transcript[0] = secret;
    for i in 0..CANDIDATE_COUNT {
        transcript[i + 1] = votes[i] as Field;
    };
    std::hash::pedersen(transcript)[0]
}

fn main(
    token_budget: pub u32,
    votes: [u32; CANDIDATE_COUNT],
    secret: Field
) -> pub Field {
    check_within_budget(token_budget, votes);
    calculate_ballot_commitment(secret, votes)
}