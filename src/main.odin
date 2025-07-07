package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"
import "core:math/rand"
import "core:time"

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

DEBUG :: true

ADDITIONAL_ANSWERS :: 1
INITIAL_ANSWERS :: 2
MAX_ANSWERS :: 3

main :: proc() {
    args := os.args

    if len(args) < 2 {
        fmt.printfln("Usage: tesutero <path/to/folder>")
        return
    }

    seed := time.time_to_unix(time.now())
    rand.reset(u64(seed))

    dir_path := args[1]
    dir_handle, err := os.open(dir_path)
    if err != nil {
        fmt.println("Failure during attempt to open directory", dir_path)
        fmt.println(err)
        return
    }
    
    defer os.close(dir_handle)
    
    entries, _ := os.read_dir(dir_handle, -1)
    // error handle

    questions: [dynamic]Question

    for entry in entries {
        if !entry.is_dir && strings.has_suffix(entry.name, ".txt") {
            question := parse_question(entry)
            append(&questions, question)
            // fmt.println("Parsed Question ID: ", question.id)
            // fmt.println("Text: ", question.text)
            // i := 1
            // for answer in question.answers {
            //     fmt.println(i, "-",  answer.is_correct, answer.text)
            //     i += 1
            // }
            // fmt.println("--------")
        }
    }

    completed_questions := 0
    number_of_questions := len(questions)
    
    // Loop
    for completed_questions < number_of_questions {
        current_question := print_random_question(&questions)
        input: [128]byte
        line, _ := os.read(os.stdin, input[:])
        fmt.println(check_the_answer(&questions, &input, &current_question))
    }

}

import "core:strconv"
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

    sort_in_place(selected)
    sort_in_place(correct)

    fmt.println(selected)
    fmt.println(correct)

    if len(selected) != len(correct) {
        return false
    }

    for i in 0..<len(selected) {
        if selected[i] != correct[i] {
            return false
        }
    }

    return true

    sort_in_place :: proc(arr: [dynamic]int) {
        for i in 0..<len(arr) {
            for j in i+1..<len(arr) {
                if arr[j] < arr[i] {
                    arr[i], arr[j] = arr[j], arr[i]
                }
            }
        }
    }
}

print_random_question :: proc(questions: ^[dynamic]Question) -> int {
    if len(questions^) == 0 {
        fmt.println("No questions, congrats..")
        return -1
    }
    
    index_rand := rand.int_max(len(questions^) - 1)

    print_question(questions, index_rand)

    return index_rand
}

print_question :: proc(questions: ^[dynamic]Question, index: int){
    fmt.printfln("[ %s ]\n", questions[index].id)
    fmt.printfln("%s\n", questions[index].text)
    i := 1
    for answer in questions[index].answers {
        // fmt.println(i, "-", answer.text)
        if answer.is_correct && DEBUG {
            fmt.printfln("  + %i. %s", i, answer.text)
        } else {
            fmt.printfln("    %i. %s", i, answer.text)
        }
        i += 1
    }
}




