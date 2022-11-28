use dep::std;

global CANDIDATE_COUNT = 2;

fn check_squared_votes_sum(vote_budget: u32, votes: [u32; CANDIDATE_COUNT]) {
    let mut vote_budget_spent: u32 = 0;
    for i in 0..CANDIDATE_COUNT {
        let vote = votes[i];
        vote_budget_spent = vote_budget_spent + (vote * vote);
    };
    constrain vote_budget_spent <= vote_budget;
}

fn hash_votes(
    votes: [u32; CANDIDATE_COUNT],
    secret: Field,
) -> Field {
    let mut transcript = [0; CANDIDATE_COUNT + 1];
    for i in 0..CANDIDATE_COUNT {
        transcript[i] = votes[i] as Field;
    };
    
    transcript[CANDIDATE_COUNT + 1] = secret;
    
    let hash = std::hash::pedersen(transcript)[0];
    hash
}

fn main(
    vote_budget: pub u32,
    votes: [u32; CANDIDATE_COUNT],
    secret: Field,
) -> pub Field {
    check_squared_votes_sum(vote_budget, votes);
    hash_votes(votes, secret)
}