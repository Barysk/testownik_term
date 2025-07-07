package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"
import "core:math"

// TODO
// Planned flags:
// -e <num> additional answers if wrong default 1
// -i <num> initial answer count default 2
// -m <num> max answer count default 3
//
// Input
// multiple answers are going using , valid answers = { 
// 1,2,3 1, 2, 3
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

parse_question :: proc(entry: os.File_Info) -> Question {
    data, _ := os.read_entire_file(entry.fullpath)
    // handle error later

    lines := strings.split_lines(string(data))
    if len(lines) < 2 {
        fmt.println("Invalid file format ", entry.name)
    }

    header := lines[0]
    if len(header) < 2 || header[0] != 'X' {
        fmt.println("Invalid header: ", header[0])
    }

    answer_count := len(header) - 1
    answer_flags := header[1:]

    question := Question {
        id = entry.name,
        text = lines[1],
        type = RandomType{
            is_done = false
        },
        count = 2
    }

    for i in 0..<answer_count {
        if i+2 >= len(lines){
            break
        }

        answer := Answer{
            is_correct = (answer_flags[i] == '1'),
            text = lines[i + 2]
        }

        append(&question.answers, answer)
    }

    return question
}

main :: proc() {
    args := os.args

    if len(args) < 2 {
        fmt.printfln("Usage: tesutero <path/to/folder>")
        return
    }

    fmt.println("args")
    fmt.println(args, "\n")

    dir_path := args[1]
    dir_handle, _ := os.open(dir_path)
    // error handle
    defer os.close(dir_handle)
    
    entries, _ := os.read_dir(dir_handle, -1)
    // error handle

    for entry in entries {
        if !entry.is_dir && strings.has_suffix(entry.name, ".txt") {
            question := parse_question(entry)
            fmt.println("Parsed Question ID: ", question.id)
            fmt.println("Text: ", question.text)
            i := 1
            for answer in question.answers {
                fmt.println(i, "-",  answer.is_correct, answer.text)
                i += 1
            }
            fmt.println("--------")
        }
    }
}
















































