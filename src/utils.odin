package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"

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

