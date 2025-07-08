package tesuteru

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/rand"
import "core:time"

// TODO
// Planned flags:
// -a <num> additional answers if wrong default 1
// -i <num> initial answer count default 2
// -m <num> max answer count default 3
// -c activates cheat mode - you see the correct answers, good initial learning
// -d deactivate ansi sequences (not recomended, use if your term doesn't support them for any reason. But consider updating your term, it not 1975 anymore bruh)
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
// If I will
// -a <num> use an alternative instead of fully random approach, good for initial learning num means number of questions in the initial pool, union for this alredy created
// -s enable save function, saves state after every question
// -S <path/to/save_file.txt> to load your save
// savings are laying down in the directory with testownik questions : saves must by dynamic, updated after every save

// Globals are good and all, but I love procedure programming
// CHEATMODE := false
// ANSI := true
// ADDITIONAL_ANSWERS : u32 = 1
// INITIAL_ANSWERS : u32 = 2
// MAX_ANSWERS : u32 = 3

// -e <num> additional answers if wrong default 1
// -i <num> initial answer count default 2
// -m <num> max answer count default 3
// -c activates cheat mode - you see the correct answers, good initial learning
// -d deactivate ansi sequences 

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
            question := parse_question(entry, &config)
            append(&questions, question)
        }
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





