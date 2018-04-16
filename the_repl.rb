# The repl loop/file executer
class TheRepl
  def start(args)
    run = true
    line_num = 0
    if !args.empty?
      file_run(args, line_num)
    else
      no_file(line_num, run)
    end
  end

  def no_file(line_num, run)
    file_read = false
    while run
      line_num += 1
      run = run_eval(nil, line_num, file_read)
    end
  end

  def file_run(args, line_num)
    file_read = true
    args.each do |the_file|
      f = File.open(the_file, 'r')
      f.each_line do |line|
        line_num += 1
        run_eval(line, line_num, file_read)
      end
      f.close
    end
  end

  $user_variables = []

  def quit_check(input)
    return true if input.empty?
    return false if input[0].casecmp('QUIT').zero?
    true
  end

  def check_variables(input)
    check_lower = ('a'..'z').to_a
    check_upper = ('A'..'Z').to_a
    return true if (input & check_lower).any? || (input & check_upper).any?
  end

  def get_variables(input)
    variables = []
    input.each do |token|
      variables.push(token) if check_variables([token])
    end
    variables
  end

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
  
  def could_not_eval(line_num)
    puts "Line #{line_num}: Couldn't evaluate expression"
  end

  def print_expression(activity, line_num, file_read)
    print_expression = evaluate_expression(activity, line_num, file_read)
    puts print_expression.to_s unless print_expression.nil?
  end

  def integer?(token)
    token.to_i.to_s == token
  end

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

  def variable_process(token, evaluation, line, file_read)
    stored_value = variable_checker(token)
    if variable_checker(token).nil?
      error_eval(1, line, token, file_read)
      return false
    else
      evaluation.push(stored_value)
    end
  end

  def evaluate_expression(activity, line, fread)
    eval = []
    activity.each do |token|
      eval = set_evaluation(token, eval, line, fread) unless eval.nil? || !eval
    end
    check_for_eval_errors(eval, fread, line)
  end

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

  def check_operators(token, evaluation, line, file_read, ops)
    op1 = ops[0]
    op2 = ops[1]
    unless ['-', '+', '/', '*'].include?(token)
      puts "Line #{line}: Could not evaluate expression"
      error_eval(5, line, nil, file_read)
      return false
    end
    evaluation.push(op1.to_i.send(token.to_sym, op2.to_i))
  end

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

  def handle_print(activity, line_num)
    if activity[1].nil?
      puts "Line #{line_num}: Operator PRINT applied to empty stack"
      -2
    else
      2
    end
  end

  def handle_let(activity, line_num, file_read)
    if activity[1].nil?
      puts "Line #{line_num}: Operator LET applied to an empty stack"
      return 0
    end
    let_no_error(activity, line_num, file_read)
  end

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

  def variable_checker(variable)
    $user_variables[variable.upcase.ord - 65]
  end

  def contains_keyword(activity)
    keyword = %w[LET PRINT]
    activity.each do |statement|
      return true if keyword.include?(statement.upcase)
    end
    false
  end

  def check_run_type(file_line)
    if !file_line.nil?
      command = file_line
    else
      print '> '
      command = gets
    end
    command.split
  end

  def handle_command(code, activity, line_num, file_read)
    case code
    when 1
      doing_let(activity, line_num, file_read)
    when 2
      doing_print(activity, line_num, file_read)
    when 3
      doing_evaluate(activity, line_num, file_read)
    when -4..-1
      abort if file_read
    end
  end

  def doing_evaluate(activity, line_num, file_read)
    val = evaluate_expression(activity, line_num, file_read).to_s
    puts val unless val.empty? || file_read
  end

  def doing_print(activity, line_num, file_read)
    activity.shift
    print_expression(activity, line_num, file_read)
  end

  def doing_let(activity, line_num, file_read)
    activity.shift
    set_val = set_variables(activity, line_num, file_read)
	puts set_val unless set_val.nil? || file_read || !set_val
  end


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
