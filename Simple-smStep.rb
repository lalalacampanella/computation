#!/usr/bin/ruby

class Boolean < Struct.new(:value)
  def reducible?
    false
  end
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
end

class Number < Struct.new(:value)
  def reducible?
    false
  end
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
end

class Add < Struct.new(:left, :right)
  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment),right)
    elsif right.reducible?
      Add.new(left,right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end
  end
  def reducible?
    true
  end
  def to_s
    "#{left} + #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
end

class Lessthan < Struct.new(:left, :right)
  def reduce(environment)
    if left.reducible?
      Lessthan.new(left.reduce(environment),right)
    elsif right.reducible?
      Lessthan.new(left,right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end
  def reducible?
    true
  end
  def to_s
    "#{left} < #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
end

class Multiply < Struct.new(:left, :right)
  def reduce(environment)
    if left.reducible?
      Multiply.new(left.reduce(environment),right)
    elsif right.reducible?
      Multiply.new(left,right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end
  def reducible?
    true
  end
  def to_s
    "#{left} * #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
end

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end
  def inspect
    "#{self}"
  end
  def reducible?
    true
  end
  def reduce(environment)
    if expression.reducible?
      [Assign.new(name,expression.reduce(environment)),environment]
    else
      [DoNothing.new,environment.merge({ name => expression })]
    end
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce(environment)
    environment[name]
  end
end

class DoNothing
  def to_s
    'do-nothing'
  end
  def inspect
    "#{self}"
  end
  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end
  def reducible?
    false
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if ( #{condition} ) { #{consequence} } else { #{alternative} }"
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce(environment)
    if condition.reducible?
      [If.new(condition.reduce(environment), consequence, alternative), environment]
    else
      case condition
      when Boolean.new(true)
        [consequence,environment]
      when Boolean.new(false)
        [alternative,environment]
      end
    end
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first}; #{second}"
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce(environment)
    case first
    when DoNothing.new
      [second,environment]
    else
      reduce_first, reduce_environment = first.reduce(environment)
      [Sequence.new(reduce_first, second), reduce_environment]
    end
  end
end

class While < Struct.new(:condition, :body)
  def to_s
    "while ( #{condition} ) { #{body} }"
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce(environment)
    [If.new(condition,Sequence.new(body,self),DoNothing.new),environment]
  end
end


class Machine < Struct.new(:statement,:environment)
  def step
    self.statement, self.environment = statement.reduce(environment)
  end

  def run
    while statement.reducible?
      puts "#{statement}, #{environment}"
      step
    end
    puts "#{statement}, #{environment}"
  end
end

#machine.new(
#  add.new(
#    multiply.new(variable.new(:qianqian),variable.new(:haobai)),
#    multiply.new(variable.new(:zeling),variable.new(:haogao)),
#  ),
#  {qianqian: number.new(1), haobai: number.new(2), zeling: number.new(3), haogao:number.new(4)}
#).run
Machine.new(

#     assign.new(:x,add.new(variable.new(:x),number.new(1))),
#     { x:number.new(2) }

#  if.new(
#    variable.new(:x),
#    assign.new(:y, number.new(1)),
#    assign.new(:y, number.new(3))
#  ),
#  { x: boolean.new(false) }

#  sequence.new(
#     assign.new(:x, add.new(variable.new(:x), number.new(2))),
#     assign.new(:y, add.new(variable.new(:x), number.new(1)))
#  ),
#  { x:number.new(2) }

  While.new(
    Lessthan.new(Variable.new(:x), Number.new(5)),
    Assign.new(:x, Multiply.new(Variable.new(:x),Number.new(3)))
  ),
  { x:Number.new(3) }

).run
