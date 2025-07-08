package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

is_number :: proc(s: string) -> bool {
    for c in s {
        if c < '0' || c > '9' {
            return false
        }
    }
    return len(s) > 0
}

help_needed :: proc(args: ^[]string) -> bool {
    i := 0
    for i < len(args) {
        arg := args[i]

        if arg == "-h" || arg == "--help" {
            return true
        }

        i += 1
    }
    return false
}

handle_flags :: proc(args: ^[]string, config: ^Config) -> Error {
    i := 1
    for i < len(args){
        arg := args[i]

        if arg == "-c" {
            config.cheatmode = true
        } else if arg == "-d" {
            config.ansimode = false
        } else if arg == "-a" && i + 1 < len(args) {
            if is_number(args[i+1]){
                val := strconv.atoi(args[i+1])
                if val > 1024 {
                    fmt.println("Too big number, you'll die doing this test")
                    return .Err
                }
                config.additional_answers = u32(val)
                i += 1
            } else {
                fmt.println("Invalid number for -a")
                return .Err
            }
        } else if arg == "-i" && i + 1 < len(args) {
            if is_number(args[i+1]){
                val := strconv.atoi(args[i+1])
                if val > 1024 {
                    fmt.println("Too big number, you'll die doing this test")
                    return .Err
                }
                if val == 0 {
                    fmt.println("Initial value can't be zero")
                    return .Err
                }
                config.initial_answers = u32(val)
                i += 1
            } else {
                fmt.println("Invalid number for -i")
                return .Err
            }
        } else if arg == "-m" && i + 1 < len(args) {
            if is_number(args[i+1]){
                val := strconv.atoi(args[i+1])
                if val > 1024 {
                    fmt.println("Too big number, you'll die doing this test")
                    return .Err
                }
                config.max_answers = u32(val)
                i += 1
            } else {
                fmt.println("Invalid number for -m")
                return .Err
            }
        } else {
            fmt.println("Those args aren't good, please refer to manual")
            return .Err
        }

        i += 1
    }

    if config.max_answers < config.initial_answers {
        fmt.println("initial value can't be bigger than max value")
        return .Err
    }

    return .Ok
}

parse_question :: proc(entry: os.File_Info, config: ^Config) -> (Question, Error) {
    data, ok := os.read_entire_file(entry.fullpath)

    if !ok {
        fmt.println("Failure during attempt to read file", entry.fullpath)
        return Question{}, .Err
    }

    lines := strings.split_lines(string(data))
    if len(lines) < 2 {
        fmt.println("Invalid file format ", entry.name)
        return Question{}, .Err
    }

    header := lines[0]
    if len(header) < 2 || header[0] != 'X' {
        fmt.println("Invalid header: ", header[0])
        return Question{}, .Err
    }

    answer_count := len(header) - 1
    answer_flags := header[1:]

    question := Question {
        id = entry.name,
        text = lines[1],
        type = RandomType{
            is_done = false
        },
        count = config.initial_answers
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

    return question, .Ok
}

check_the_answer :: proc(
    questions: ^[dynamic]Question,
    input: ^[128]byte,
    current_question: ^int
) -> bool {

    line := string(input[:])
    line = strings.trim_space(line)
    line, _ = strings.replace_all(line, " ", "")

    parts := strings.split(line, ",")

    selected: [dynamic]int
    for part in parts {
        if part == "" {
            continue
        }
        val := strconv.atoi(part)
        append(&selected, val)
    }

    correct: [dynamic]int
    i := 1
    for answer in questions[current_question^].answers {
        if answer.is_correct {
            append(&correct, i)
        }
        i += 1
    }

    sort.quick_sort(selected[:])
    sort.quick_sort(correct[:])

    if len(selected) != len(correct) {
        return false
    }

    for i in 0..<len(selected) {
        if selected[i] != correct[i] {
            return false
        }
    }

    return true
}

