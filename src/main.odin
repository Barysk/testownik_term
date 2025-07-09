package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/rand"
import "core:time"

main :: proc() {
    args := os.args[1:]

    config := Config {
        cheatmode = false,
        ansimode = true,
        additional_answers = 1,
        initial_answers = 2,
        max_answers = 3
    }

    if help_needed(&args) {
        print_help()
        return
    }

    if handle_flags(&args, &config) != .Ok {
        print_help()
        return
    }

    if len(args) < 1 {
        print_help()
        return
    }

    seed := time.time_to_unix(time.now())
    rand.reset(u64(seed))

    dir_path := args[0]
    dir_handle, err := os.open(dir_path)
    if err != nil {
        fmt.println("Failure during attempt to open directory", dir_path)
        print_help()
        return
    }

    defer os.close(dir_handle)

    entries: []os.File_Info
    entries, err = os.read_dir(dir_handle, -1)
    if err != nil {
        fmt.println("Failure during attempt to read directory", dir_path)
        print_help()
        return
    }

    questions: [dynamic]Question

    for entry in entries {
        if !entry.is_dir && strings.has_suffix(entry.name, ".txt") {
            question, ok := parse_question(entry, &config)
            if ok != .Ok {
                fmt.printfln("File %s probably has incorrect format", entry.name)
                return
            }
            append(&questions, question)
        }
    }

    if len(questions) == 0 {
        fmt.println("No proper questions found in directory ", dir_path)
        return
    }

    testing_data := TestingData {
        completed_questions = 0,
        number_of_questions = u32(len(questions)),
        correct_answers = 0,
        incorrect_answers = 0,
    }

    start := time.now()
    clear_term(&config)

    for testing_data.completed_questions < testing_data.number_of_questions {
        show_answers := config.cheatmode

        // update
        current_question := choose_random_question(&questions)

        // draw
        print_data(
            &dir_path,
            &questions[current_question].id,
            &questions[current_question].count,
            &testing_data,
            &config
        )
        print_question(&questions, &current_question, &show_answers, &config)

        // handle input
        input: [128]byte
        line, _ := os.read(os.stdin, input[:])

        // draw correct answers
        show_answers = true
        clear_term(&config)
        print_data(
            &dir_path,
            &questions[current_question].id,
            &questions[current_question].count,
            &testing_data,
            &config
        )
        print_question(&questions, &current_question, &show_answers, &config)

        switch check_the_answer(&questions, &input, &current_question) {
        case true:
            correct_answer( &questions, &current_question, &testing_data, &config)
        case false:
            incorrect_answer(&questions, &current_question, &testing_data, &config)
        }

        // wait on input input
        line, _ = os.read(os.stdin, input[:])
        clear_term(&config)
    }
    elapsed := time.since(start)
    print_stat(&dir_path, &testing_data, &elapsed, &config)
    print_congrats(&config, &testing_data)
}

correct_answer :: proc(
    questions: ^[dynamic]Question,
    current_question: ^int,
    testing_data: ^TestingData,
    config: ^Config
) {
    if config.ansimode {
        fmt.println(ANSI_S + "Correct\n" + ANSI_RST)
    } else {
        fmt.println("Correct\n")
    }

    questions[current_question^].count -= 1

    if questions[current_question^].count <= 0 {
        questions[current_question^].type = RandomType { is_done = true }
    }

    testing_data^.correct_answers += 1

    i := 0

    for question in questions^ {
        if question.type.(RandomType).is_done == true {
            // fmt.println(question.type)
            ordered_remove(questions, i)
            testing_data.completed_questions += 1
        }
        i += 1
    }
}

incorrect_answer :: proc(
    questions: ^[dynamic]Question,
    current_question: ^int,
    testing_data: ^TestingData,
    config: ^Config
) {
    if config.ansimode {
        fmt.println(ANSI_C + "Wrong\n" + ANSI_RST)
    } else {
        fmt.println("Wrong\n")
    }

    testing_data^.incorrect_answers += 1

    if questions[current_question^].count < config.max_answers {
        questions[current_question^].count += config.additional_answers
        if questions[current_question^].count > config.max_answers {
            questions[current_question^].count = config.max_answers
        }
    }
}


// TODO Possible future development
// -h <num> use an alternative instead of fully random approach, good for initial learning num means number of questions in the initial pool, union for this alredy created
// -s enable save function, saves state after every question
// -S <path/to/save_file.txt> to load your save
// savings are laying down in the directory with testownik questions : saves must by dynamic, updated after every save
