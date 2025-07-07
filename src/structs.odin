package tesuteru

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

