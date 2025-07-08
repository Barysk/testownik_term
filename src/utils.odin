package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

parse_question :: proc(entry: os.File_Info) -> Question {
    data, ok := os.read_entire_file(entry.fullpath)

    if !ok {
        fmt.println("Failure during attempt to read file", entry.fullpath)
        return Question{}
    }

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
        count = INITIAL_ANSWERS
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

