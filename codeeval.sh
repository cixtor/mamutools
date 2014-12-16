#!/bin/bash
#
# CodeEval
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://www.codeeval.com/
#
# CodeEval is a platform used by developers to showcase their skills. Developers
# can participate in app building competitions and win cash/prizes. They can also
# solve programming challenges as a way to impress employers with their technical
# skills. Employers can use CodeEval as a way to enhance their brand by launching
# competitions/programming challenges and as a means to get introduced to the best
# developers.
#
IFS=$'\n'

if [[ "$1" != "" ]]; then
    exec_command='null'
    solution_file="${1}"
    debug_unit_test="${2}"
    temp_input_file='temp.input.txt'
    unit_test_file='temp.unittest.php'
    extension=$(echo "${solution_file}" | rev | cut -d '.' -f 1 | rev)

    case $extension in
        'cpp' ) exec_command="g++ -o test.bin ${solution_file} && ./test.bin %s && rm test.bin";;
    esac

    input_values=()
    output_values=()

    for line in $(cat input.txt); do
        input_values+=($line)
    done

    for line in $(cat output.txt); do
        output_values+=($line)
    done

    total_cases="${#input_values[@]}"

    echo '<?php' > $unit_test_file
    echo 'function validate_solution( $text="" ){' >> $unit_test_file
    echo "    \$temp_input_file = '$temp_input_file';" >> $unit_test_file
    echo "    \$exec_command = sprintf( '$exec_command', \$temp_input_file );" >> $unit_test_file
    echo '    file_put_contents( $temp_input_file, $text, LOCK_EX );' >> $unit_test_file
    echo "    return exec(\$exec_command);" >> $unit_test_file
    echo '}' >> $unit_test_file

    echo 'class CodeEvalTest extends PHPUnit_Framework_TestCase {' >> $unit_test_file
    for (( i=0; i<$total_cases; i++ )); do
        inputstr=$(echo "${input_values[$i]}" | sed "s/'/\\\'/g")
        expected=$(echo "${output_values[$i]}" | sed "s/'/\\\'/g")
        echo "    public function test_codeeval_case_$i(){" >> $unit_test_file
        echo "        \$this->assertEquals( '$expected', validate_solution('$inputstr') );" >> $unit_test_file
        echo '    }' >> $unit_test_file
    done
    echo '}' >> $unit_test_file

    if [[ "${debug_unit_test}" == "--debug" ]]; then
        cat $unit_test_file && exit 0
    fi

    phpunit --color $unit_test_file
    rm -fv $unit_test_file
    rm -fv $temp_input_file
fi
