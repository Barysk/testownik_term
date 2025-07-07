package tesotero

import fmt "core:fmt"

// TODO
// Planned flags:
// -e <num> additional answers if wrong default 1
// -i <num> initial answer count default 2
// -m <num> max answer count default 3
//
// Input
// multiple answers are going using , valid answers = { 
// 1,2,3 
// 1, 2, 3
// 1,2 ,3,
// 2
// 3,
// }
//
// Misc:
// show question file names
// show stat [Wrong answers / Correct answers]
// show number of questions that are no longer appear. 'Opanowane' [num]
// show number of questions that are going appear. 'Do opanowania' [num]
// show [time passed]
//
// Additional
// -h <num> use heuristic instead of fully random, good for initial learning num means number of questions in the initial pool
// -s enable save function, saves state after every question
// -S <path/to/save_file.txt> to load your save
// savings are laying down in the directory with testownik questions : saves must by dynamic, updated after every save


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


main :: proc() {
    fmt.print("hellope world")
}
