package tesuteru

TestingData :: struct {
    completed_questions: u32,
    number_of_questions: u32,
    correct_answers: u32,
    incorrect_answers: u32,
}

RandomType :: struct {
    is_done: bool
}

HeuristicType :: struct {
    is_chosen: bool,
    is_done: bool
}

Type :: union {
    RandomType,
    HeuristicType
}

Answer :: struct {
    is_correct: bool,
    text: string,
}

Question :: struct {
    id: string,
    text: string,
    answers: [dynamic]Answer,
    type: Type,
    count: u32,
}

Config :: struct {
    cheatmode: bool,
    ansimode: bool,
    additional_answers: u32,
    initial_answers: u32,
    max_answers: u32,
}

Error :: enum {
    Ok,
    Err
}
