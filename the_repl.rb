# The repl loop/file executer
class TheRepl
  # First method called by executed class RPN
  # Checks whether this is being run with files or repl mode
  def start(args)
    run = true
    line_num = 0
    if !args.empty?
      file_run(args, line_num)
    else
      no_file(line_num, run)
    end
  end

  # This activates repl mode and iterates the line count
  def no_file(line_num, run)
    file_read = false
    while run
      line_num += 1
      run = run_eval(nil, line_num, file_read)
    end
  end

  # Simple handler for a file
  def handle_file(the_file)
    begin
      f = File.open(the_file, 'r')
    rescue SystemCallError
      puts "No such file: #{the_file}"
      return false
    end
    f
  end

  # This is the file mode, iterates over every line of the files
  # and keeps track of the line number
  def file_run(args, line_num)
    file_read = true
    args.each do |the_file|
      f = handle_file(the_file)
      exit 5 unless f
      f.each_line do |line|
        line_num += 1
        run_eval(line, line_num, file_read)
      end
      f.close
    end
  end

  # This is part of the rubocop errors
  # I can't think of a way to eliminate this without
  # massive overhaul and i've had no issues with it
  $user_variables = []
  # Method called to check if the user enter the command QUIT
  # Ignores anything other than the first word input
  def quit_check(input)
    return true if input.empty?
    return false if input[0].casecmp('QUIT').zero?
    true
  end

  # This returns true if the statement passed in contains_keyword
  # any individual alphabetical characters
  def check_variables(input)
    check_lower = ('a'..'z').to_a
    check_upper = ('A'..'Z').to_a
    return true if (input & check_lower).any? || (input & check_upper).any?
  end

  # This returns the individual alphabetical characters from an input
  def get_variables(input)
    variables = []
    input.each do |token|
      variables.push(token) if check_variables([token])
    end
    variables
  end

  # This sets the variable being LET by the user
  # At this point let has been removed from the statement(activity)
  # Throws an error if there's no value after the variable or
  # the first argument isn't a variable
  # Otherwise, evaluates the expression and sets the variable
  def set_variables(activity, line_num, file_read)
    val = activity[0].upcase.ord
    return could_not_eval(line_num) unless check_variables([activity[0]])
    if activity[1].nil?
      puts "Line #{line_num}: operator LET applied to empty stack"
      error_eval(2, line_num, nil, file_read)
    else
      activity.shift
      store = evaluate_expression(activity, line_num, file_read)
      $user_variables[val - 65] = store unless store.nil?
    end
  end

  # Method only used by set_variables to throw error
  def could_not_eval(line_num)
    puts "Line #{line_num}: Couldn't evaluate expression"
  end

  # Method called to evaluate expression and print as long as
  # evaluate expression did not return nil (means error was already thrown)
  def print_expression(activity, line_num, file_read)
    print_expression = evaluate_expression(activity, line_num, file_read)
    puts print_expression.to_s unless print_expression.nil?
  end

  # Method i'm slightly worried about but seems to work perfect
  # Returns true if item passed in is an integer, false otherwise
  def integer?(token)
    token.to_i.to_s == token
  end

  # Used to throw some errors but mostly used for exiting
  # in case of error in file
  def error_eval(code, line, extra, file_read)
    case code
    when 1
      puts "Line #{line}: Variable #{extra} has not been initialized"
    when 3
      puts "Line #{line}: #{extra} elements in stack after evaluation"
    end
    exit code if file_read
    nil
  end

  # This method gets called until no more items
  # left in the users expression
  # pushes integers on the stack, calls variable process
  # if a variable is used otherwise calls perform op1
  # for operators
  # Always returns the RPN stack
  def set_evaluation(token, evaluation, line, file_read)
    val = token.upcase.ord
    if integer?(token)
      evaluation.push(token)
    elsif (val < 91) & (val > 64) & check_variables([token])
      variable_process(token, evaluation, line, file_read)
    else
      perform_op(token, evaluation, line, file_read)
    end
  end

  # Makes sure value passed in is in fact a variable
  # then checks if stored value is nil to throw error
  # and returns false so previous methods don't also throw an error
  # otherwise pushes variable and returns the stack
  def variable_process(token, evaluation, line, file_read)
    stored_value = variable_checker(token)
    if variable_checker(token).nil?
      error_eval(1, line, token, file_read)
      return false
    else
      evaluation.push(stored_value)
    end
  end

  # Calls the set evaluation method for every item
  # in the user expression (activity)
  # Calls check for eval errors and returns what it returns
  def evaluate_expression(activity, line, fread)
    eval = []
    activity.each do |token|
      eval = set_evaluation(token, eval, line, fread) unless eval.nil? || !eval
    end
    check_for_eval_errors(eval, fread, line)
  end

  # If stack is false, error was already thrown
  # If stack is nil, error must be thrown
  # If there are more than 1 item on the stack then error is thrown
  # Otherwise the stack is returned with the expression evaluation value
  def check_for_eval_errors(evaluation, file_read, line)
    return nil if evaluation == false
    if evaluation.nil?
      puts 'Could not evaluate expression'
      nil
    elsif evaluation.length > 1
      error_eval(3, line, evaluation.length, file_read)
      nil
    else
      evaluation[0]
    end
  end

  # Performs every operation of an expression
  # by taking the two numbers off the stack and throws
  # errors if either is nil
  # otherwise, packs them up and returns whatever check_operators
  # returns
  def perform_op(token, evaluation, line, file_read)
    op2 = evaluation.pop
    op1 = evaluation.pop
    if op1.nil? || op2.nil?
      puts "Line #{line}: Operator #{token} applied to an empty stack"
      error_eval(2, line, nil, file_read)
      return false
    end
    ops = [op1, op2]
    check_operators(token, evaluation, line, file_read, ops)
  end

  # Throws error if incorrect operators are used
  # and returns false to say it already threw an error
  # Otherwise it evaluates the expression and returns the stack
  # Also checks for /0
  def check_operators(token, evaluation, line, file_read, ops)
    op1 = ops[0]
    op2 = ops[1]
    unless ['-', '+', '/', '*'].include?(token) && !(token == '/' && op2.to_i.zero?)
      puts "Line #{line}: Could not evaluate expression"
      error_eval(5, line, nil, file_read)
      return false
    end
    evaluation.push(op1.to_i.send(token.to_sym, op2.to_i))
  end

  # Returns what type of command is being done
  # Throws an error if the first item in command
  # is not a known keyword, a single alphabetical characters
  # or an integer, returns -4 as code for error
  # code is converted back to positive for exit status later
  def type_check(activity, line_num, file_read)
    if contains_keyword(activity)
      handle_keywords(activity, line_num, file_read)
    elsif check_variables(activity)
      handle_variables(activity, line_num)
    elsif integer?(activity[0])
      3
    else
      puts "Line #{line_num}: unknown keyword #{activity[0]}"
      -4
    end
  end

  # If let or print are in the command but not the
  # first word then the error is thrown, calls error_eval
  # to exit with code 5 if necessary, otherwise returns 0
  # which does nothing
  def handle_keywords(activity, line_num, file_read)
    if activity[0].casecmp('LET').zero?
      handle_let(activity, line_num, file_read)
    elsif activity[0].casecmp('PRINT').zero?
      handle_print(activity, line_num)
    else
      puts "Line #{line_num}: Could not evaluate expression"
      error_eval(5, line_num, nil, file_read)
      0
    end
  end

  # Throws error if print is the only thing in user command
  # otherwise, returns the value 2 to indicate to call print_expression
  def handle_print(activity, line_num)
    if activity[1].nil?
      puts "Line #{line_num}: Operator PRINT applied to empty stack"
      -2
    else
      2
    end
  end

  # Throws error if let is the only thing in user command
  # otherwise, returns whatever let_no_error returns
  def handle_let(activity, line_num, file_read)
    if activity[1].nil?
      puts "Line #{line_num}: Operator LET applied to an empty stack"
      return 0
    end
    let_no_error(activity, line_num, file_read)
  end

  # Ensures the next word in the command after let is an
  # individual alphabetical character, returns 1 if so, otherwise throws error
  # calls error eval in case exit required, otherwise returns 0
  # to do nothing
  def let_no_error(activity, line_num, file_read)
    val = activity[1].ord
    if ((val < 91) & (val > 64)) || ((val > 96) & (val < 123))
      1
    else
      puts "Line #{line_num}: No variable specified"
      error_eval(5, line_num, nil, file_read)
      0
    end
  end

  # Gets the variables present in a user command
  # and ensures each one is usable, as in not nil
  # Throws error if any nil variables are found, otherwise
  # returns 3 to indicate an expression is present
  def handle_variables(activity, line_num)
    variables = get_variables(activity)
    variables.each do |variable|
      if variable_checker(variable).nil?
        puts "Line #{line_num}: Variable #{variable} is not initialized"
        return -1
      end
    end
    3
  end

  # Used to limit number of times global variable was referenced
  # returns nil if variable is nil, otherwise returns value of the variable
  def variable_checker(variable)
    $user_variables[variable.upcase.ord - 65]
  end

  # Returns true if the statement includes either keywords
  # print or let regardless of case, otherwise returns false
  def contains_keyword(activity)
    keyword = %w[LET PRINT]
    activity.each do |statement|
      return true if keyword.include?(statement.upcase)
    end
    false
  end

  # Returns the file line as the command if it's not nil
  # otherwise gets input from the user and returns an array of
  # whitespace delimited characters/words
  def check_run_type(file_line)
    if !file_line.nil?
      command = file_line
    else
      print '> '
      command = gets
    end
    command.split
  end

  # Upon receiving the code returned by typecheck, run_eval
  # sends it to this method which calls the appropriate
  # method to handle the users command
  # exits with specified exit code if necessary
  def handle_command(code, activity, line_num, file_read)
    case code
    when 1
      doing_let(activity, line_num, file_read)
    when 2
      doing_print(activity, line_num, file_read)
    when 3
      doing_evaluate(activity, line_num, file_read)
    when -4..-1
      exit code.abs if file_read
    end
  end

  # Handles when an expression is used as the command
  # Evaluates the expression and prints it out unless
  # the value is nil (error was thrown) or we're reading from a file
  def doing_evaluate(activity, line_num, file_read)
    val = evaluate_expression(activity, line_num, file_read).to_s
    puts val unless val.empty? || file_read
  end

  # Removes the keyword print and calls the print_expression
  # method to print out the evaluated expression
  def doing_print(activity, line_num, file_read)
    activity.shift
    print_expression(activity, line_num, file_read)
  end

  # Removes the keyword let and calls the set_variables
  # method then prints out the value unless nil or false was returned
  # (error was thrown) or a file was being read
  def doing_let(activity, line_num, file_read)
    activity.shift
    set_val = set_variables(activity, line_num, file_read)
    puts set_val unless set_val.nil? || file_read || !set_val
  end

  # Calls the functions to check if user input is needed or file is being read,
  # returns if empty line, checks if user tried to quit_check,
  # ends the program if run is returned as false (quit was entered)
  # Otherwise check the type of command and sends the code to be handled
  # returns run so repl mode knows to continue
  def run_eval(file_line, line_num, file_read)
    activity = check_run_type(file_line)
    return true if activity[0].nil?

    run = quit_check(activity)

    unless run
      return run if file_line.nil?
      abort
    end
    code = type_check(activity, line_num, file_read)
    handle_command(code, activity, line_num, file_read)
    run
  end
end
