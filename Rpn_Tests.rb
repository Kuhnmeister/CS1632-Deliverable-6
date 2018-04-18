require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require_relative 'the_repl'


class Rpn_Tests < Minitest::Test
	
	# checks if the method handle file properly returns false 
	# without raising an error if the file name does not exit
	def test_handle_file
		tester = TheRepl.new()
		assert_output ("No such file: ffffffff\n") {
		  assert_equal false, tester.handle_file("ffffffff")
		}
	end
	# checks if the method quit_check returns properly with the a token array of 'QUIT'
	# will return false if there is a quit
	def test_quit_check_true_1
	    tester = TheRepl.new()
		assert_equal false, tester.quit_check(['QUIT'])
	end
	
	# checks if the method quit_check will properly ignore case and extra variables
	def test_quit_check_true_2
		tester = TheRepl.new()
		assert_equal false, tester.quit_check(['QUIt', 'let', 'a', '9'])
	end
	
	# checks if quit check will properly ignore case
	def test_quit_check_true_3
		tester = TheRepl.new()
		assert_equal false, tester.quit_check(['QUit'])
	end
	
	# checks if quit check will return false if garbage happens after the quit 
	def test_quit_check_true_4
		tester = TheRepl.new()
		assert_equal false, tester.quit_check(['quit', 'cheese'])
	end
	
	# checks if quit check will return true if not given quit
	def test_quit_check_false_1
		tester = TheRepl.new()
		assert_equal true, tester.quit_check(['quot'])
	end
	
	# checks if quit_check will still return true when given an input
	# that is quit then some letters
	def test_quit_check_false_2
		tester = TheRepl.new()
		assert_equal true, tester.quit_check(['quitlle'])
	end
	
	# Corner case
	# checks if quit_check will return false if given an empty array
	def test_quit_check_corner
		tester = TheRepl.new()
		assert_equal true, tester.quit_check([])
	end
	
	# tests if check_variables is given at least one valid variable
	# it returns true
	def test_variable_check_true_1
		tester = TheRepl.new()
		assert_equal true, tester.check_variables(['ask', 'for', 'a', 'dog'])
	end
	
	# Again tests if check_variables can find one valid variable
	def test_variable_check_true_2
		tester = TheRepl.new()
		assert_equal true, tester.check_variables(['b', 'cause', 'turkey'])
	end
	
	# makes sure that if check_variables is given no valid variables
	# it returns nil
	def test_variable_check_false_1
		tester = TheRepl.new()
		assert_nil tester.check_variables(['as', 'yu', 're'])
	end
	
	# again checks if nil is properly returned when there are no valid 
	# variables
	def test_variable_check_false_2
		tester = TheRepl.new()
		assert_nil tester.check_variables(['chips'])
	end
	
	# checks a usual case where the input to check_variables is
	# just numbers, nil should be returned
	def test_variable_check_corner_1
		tester = TheRepl.new()
		assert_nil tester.check_variables([1, 2, 3])
	end
	
	# checks that an empty array correctly returns nil
	def test_variable_check_corner_2
		tester = TheRepl.new()
		assert_nil tester.check_variables([])
	end
	
	# checks that get_variables is able to find valid variables among garbage
	def test_get_variables_1
		tester = TheRepl.new()
		assert_equal ['a', 'g', 'z'], tester.get_variables(['a', 'bbb', 'cc', 'g', 'doggy', 'z'])
	end
	
	# tests if there are no valid variables get_variables will return an 
	# empty array
	def test_get_variables_2
		tester = TheRepl.new()
		assert_equal [], tester.get_variables(['chips', 'lips'])
	end
	
	# Makes sure get_variables can handle an empty array
	def test_get_variables_corner
		tester = TheRepl.new()
		assert_equal [], tester.get_variables([])
	end
	
	# Tests if set_variable properly rejects a single invalid character 
	# as shown by returning nil which is the return value of the puts error message
	def test_set_variables_1
		tester = TheRepl.new()
		assert_nil tester.set_variables([';'], 1, false)
	end
	
	# Test the actual output of the error message when an variable is given]
	# with no expression
	def test_set_variables_2
		tester = TheRepl.new()
		assert_output("Line 27: operator LET applied to empty stack\n", nil) { tester.set_variables(['a'], 27, false) }
		assert_nil tester.set_variables(['a'], 27, false)
	end
	
	# Tests that the expression for a is properly evaluated and returned,
	# showing that it has been stored in a
	def test_set_variables_3
		tester = TheRepl.new()
		assert_equal 19, tester.set_variables(['a', '9', '10', '+'], 1, false)
	end
	
	# Tests the output of when the print key word has been found
	def test_print_expression_1
		tester = TheRepl.new()
		assert_output("19\n") { tester.print_expression(['9', '10', '+'], 1, false) }
	end
	
	# Tests the error message if the variable t is not initialized before it is 
	# used in an expression and printed
	def test_print_expression_2
		tester = TheRepl.new()
		assert_output("Line 19: Variable t has not been initialized\n") { tester.print_expression(['t', '10', '+'], 19, false) }
	end
	
	# Makes sure print_expression prints nothing if invalid
	def test_print_expression_3
		tester = TheRepl.new()
		def tester.evaluate_expression(bla, blah, blahs); nil; end
		assert_silent { tester.print_expression(['blah'], 1, false) }
	end
	
	# Tests if integer? can identify a larger int
	def test_1_integer?
		tester = TheRepl.new()
		assert_equal true, tester.integer?('12345')
	end
	
	# Tests if a common character will be shown not to be an int
	def test_2_integer?
		tester = TheRepl.new()
		assert_equal false, tester.integer?('a')
	end
	
	# Tests if a rare single character can be determined not to be an int
	def test_3_integer?
		tester = TheRepl.new()
		assert_equal false, tester.integer?(';')
	end
	
	# Tests if a word will be determined to be an int
	def test_4_integer?
		tester = TheRepl.new()
		assert_equal false, tester.integer?('quelf')
	end
	
	# Corner Case
	# Tests if an empty string will be determined an int
	def test_5_integer?
		tester = TheRepl.new()
		assert_equal false, tester.integer?('')
	end	
	
	# Tests the output and return value of error_eval of mode 1
	def test_error_eval_1
		tester = TheRepl.new()
		assert_output("Line 397: Variable K has not been initialized\n") { tester.error_eval(1, 397, 'K', false) }
		assert_nil tester.error_eval(1, 397, 'K', false)
	end
	
	# Tests the output of mode 3
	def test_error_eval_2
		tester = TheRepl.new()
		assert_output("Line 3687: 47 elements in stack after evaluation\n") { tester.error_eval(3, 3687, 47, false) }
		assert_nil tester.error_eval(3, 3687, 47, false)
	end
	
	# tests the simple case of evaluating the last token of an expression
	def test_set_evaluation_1
		tester = TheRepl.new()
		assert_equal ["49876"], tester.set_evaluation('49876', [], 1, false)
	end
	
	# Tests that an invalid last expression returns false
	def test_set_evaluation_2
		tester = TheRepl.new()
		assert_equal false, tester.set_evaluation('n', [], 1, false)
	end
	
	# Tests if once a variable is set it is properly treated as the number it 
	# was set to
	def test_set_evaluation_3
		tester = TheRepl.new()
		tester.set_variables(['a', '97'], 1, false)
		assert_equal ["97"], tester.set_evaluation('a', [], 1, false)
	end	
	
	# Tests that when there is a hanging operator that the set_evaluation properly
	# returns false and prints out an errors message
	def test_set_evaluation_4
		tester = TheRepl.new()
		assert_output("Line 6789: Operator * applied to an empty stack\n") { tester.set_evaluation('*', [], 6789, false) }
		assert_equal false, tester.set_evaluation('*', [], 6789, false)
	end
	
	# Tests a simple case of multiplying two numbers together 
	# returns the proper result
	def test_set_evaluation_5
		tester = TheRepl.new()
		assert_equal [91], tester.set_evaluation('*', ['7', '13'], 1, false)
	end
	
	# Tests that a non initialized variable returns false 
	# and outputs the correct error message
	def test_variable_process_1
		tester = TheRepl.new()
		assert_output("Line 1928: Variable z has not been initialized\n") { tester.variable_process('z', [], 1928, false) }
		assert_equal false, tester.variable_process('z', [], 1928, false)
	end
	
	# Tests non initialized error message
	def test_variable_process_2
		tester = TheRepl.new()
		assert_output("Line 2837: Variable ; has not been initialized\n") { tester.variable_process(';', [], 2837, false) }
		assert_equal false, tester.variable_process(';', [], 2837, false)
	end
	
	# Tests that when variable_process is called on a variable that has been set
	# it returns that value
	def test_variable_process_3
		tester = TheRepl.new()
		tester.set_variables(['a', '97'], 1, false)
		assert_equal ["97"], tester.variable_process('a', [], 1, false)
	end
	
	# Tests if there is no operators that evaluate_expression
	# returns nil
	def test_evaluate_expression_1
		tester = TheRepl.new()
		def tester.set_evaluation(token, eval, line, fread); false; end
		assert_nil tester.evaluate_expression(['1','2','3'], 1, false)
	end
	
	# Tests the proper error message is output if there are no operators
	def test_evaluate_expression_2
		tester = TheRepl.new()
		def tester.set_evaluation(token, eval, line, fread); nil; end
		assert_output("Could not evaluate expression\n") { tester.evaluate_expression(['1'], 1, false) }
		assert_nil tester.evaluate_expression(['1'], 1, false)
	end
	
	# Tests the error message when things are left on the stack
	def test_check_eval_errors_1
		tester = TheRepl.new()
		assert_output("Line 4856: 4 elements in stack after evaluation\n") { tester.check_for_eval_errors(['1','2','3','4'], false, 4856) }
		assert_nil tester.check_for_eval_errors(['1','2','3','4'], false, 4856)
	end
	
	# Checks when there is only 1 number on the stack that that number is returned
	def test_check_eval_errors_2
		tester = TheRepl.new()
		assert_equal '192837465', tester.check_for_eval_errors(['192837465'], false, 1)
	end
	
	# checks in a simple case that run_eval returns true
	def test_run_eval_1
		tester = TheRepl.new()
		def tester.check_run_type(file_line); []; end
		assert_equal true, tester.run_eval("", 1, false)
	end
	
	def test_run_eval_2
		tester = TheRepl.new()
		def tester.check_run_type(file_line); ['1']; end
		def tester.quit_check(activity); false; end
		assert_equal false, tester.run_eval(nil, 1, false)
	end
	
	def test_run_eval_2
		tester = TheRepl.new()
		def tester.check_run_type(file_line); ['1']; end
		def tester.quit_check(activity); true; end
		def tester.type_check(activity, line_num, file_read); 1; end
		def tester.handle_command(code, activity, line_num, file_read); 1; end
		assert_equal true, tester.run_eval(nil, 1, false)
	end
	
	def test_doing_let_1
		tester = TheRepl.new()
		def tester.set_variables(activity, line_num, file_read); 37456; end
		assert_output("37456\n") { tester.doing_let([], 1, false) }
	end
	
	def test_doing_let_2
		tester = TheRepl.new()
		def tester.set_variables(activity, line_num, file_read); 37456; end
		assert_silent { tester.doing_let([], 1, true) }
	end
	
	def test_doing_let_2
		tester = TheRepl.new()
		def tester.set_variables(activity, line_num, file_read); nil; end
		assert_silent { tester.doing_let([], 1, false) }
	end
	
	def test_doing_print_1
		tester = TheRepl.new()
		assert_output("247\n") { tester.doing_print(["print", "200", "40", "7", "+", "+"], 1, false) }
	end
	
	def test_doing_evaluate_1
		tester = TheRepl.new()
		assert_output("247\n") { tester.doing_evaluate([ "200", "40", "7", "+", "+"], 1, false) }
	end
	
	def test_doing_evaluate_2
		tester = TheRepl.new()
		assert_output("Line 13579: Variable h has not been initialized\n") { tester.doing_evaluate([ "h", "40", "7", "+", "+"], 13579, false) }
	end
	
	def test_doing_evaluate_3
		tester = TheRepl.new()
		def tester.evaluate_expression(activity, line_num, file_read); ""; end
		assert_silent { tester.doing_evaluate([], 1, false) }
	end
	
	def test_handle_command_1
		tester = TheRepl.new()
		assert_output("987654321\n") { tester.handle_command(1, ["let", "u", "987654321"], 1, false) }
	end
	
	def test_handle_command_2
		tester = TheRepl.new()
		assert_output("987654321\n") { tester.handle_command(2, ["print", "987654321"], 1, false) }
	end
	
	def test_handle_command_3
		tester = TheRepl.new()
		assert_output("") { tester.handle_command(2, ["print"], 1, false) }
	end
	
	def test_handle_command_4
		tester = TheRepl.new()
		assert_output("949494\n") { tester.handle_command(3, ["940000", "9400", "94", "+", "+"], 1, false) }
	end
	
	def test_handle_command_5
		tester = TheRepl.new()
		assert_output("") { tester.handle_command(3, [], 1, false) }
	end
	
	def test_contains_keyword_1
		tester = TheRepl.new()
		assert_equal true, tester.contains_keyword(["friends", "don't", "let", "friends"])
	end
	
	def test_contains_keyword_2
		tester = TheRepl.new()
		assert_equal false, tester.contains_keyword(["friends", "don't", "friends"])
	end
		
	def test_contains_keyword_3
		tester = TheRepl.new()
		assert_equal false, tester.contains_keyword([])
	end
	
	def test_handle_variables_1
		tester = TheRepl.new()
		assert_output("Line 54327890: Variable r is not initialized\n") { tester.handle_variables(["r"], 54327890) }
		assert_equal -1, tester.handle_variables(["r"], 54327890)
	end
	
	def test_handle_variables_2
		tester = TheRepl.new()
		tester.set_variables(['a', '97'], 1, false)
		assert_equal 3, tester.handle_variables(['a'], 1)
	end
	
	def test_let_no_error_1
		tester = TheRepl.new()
		assert_equal 1, tester.let_no_error(["", "h"], 1, false)
	end
	
	def test_let_no_error_2
		tester = TheRepl.new()
		assert_output("Line 4999: No variable specified\n") { tester.let_no_error(["", ";"], 4999, false) }
		assert_equal 0, tester.let_no_error(["", ";"], 1, false)
	end
	
	
		
		
		
end
	
	
	
	
	
	
	
	
	