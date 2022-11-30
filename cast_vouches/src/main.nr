use dep::std;

// Number of candidates on ballot card
global CANDIDATE_COUNT = 10;

// Constrains votes to obey QV cost function
fn check_within_budget(token_budget: u32, votes: [u32; CANDIDATE_COUNT]) {
    // Sum squared votes into this variable
    let mut tokens_spent: u32 = 0;
    // Loop over the vote for each candidate
    for i in 0..CANDIDATE_COUNT {
        let vote = votes[i];
        // Accumulate each squared vote
        tokens_spent = tokens_spent + (vote * vote);
    };
    // Check we haven't used more tokens than allowed
    constrain tokens_spent <= token_budget;
}

// Hashes the contents of a ballot using pedersen
fn calculate_ballot_commitment(
    secret: Field,
    votes: [u32; CANDIDATE_COUNT]
) -> Field {
    // Form the transcript by prepending the votes with the secret
    // Note: In the future it will be possible to size this array
    // more flexibly with the use of comptime expressions.
    let mut transcript = [0; CANDIDATE_COUNT + 1];
    transcript[0] = secret;
    for i in 0..CANDIDATE_COUNT {
        // Pedersen expects a transcript of Field elements, hence the cast
        transcript[i + 1] = votes[i] as Field;
    };
    // Return the x coordinate of the resulting EC point
    std::hash::pedersen(transcript)[0]
}

// Performed by a user who wishes to hide their ballot while proving
// that they have obeyed the rules of Quadratic Voting
fn main(
    // Budget to be enforced
    token_budget: pub u32,
    // The votes for each candidate (identified by index)
    votes: [u32; CANDIDATE_COUNT],
    // For shielding the commitment from brute-force attacks
    secret: Field
) -> pub Field {
    // Enforce QV rules
    check_within_budget(token_budget, votes);
    // Reveal the commitment
    calculate_ballot_commitment(secret, votes)
}