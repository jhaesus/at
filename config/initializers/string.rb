class String
  def demod
    if i = index("::")
      self[(i+2)..-1]
    else
      self
    end
  end

  def deconst
    if i = index("::")
      self[0..(i-1)]
    else
      self
    end
  end
end

class BigDecimal
  def inspect
    to_s("F")
  end
end

class Float
  def inspect
    BigDecimal(to_s).to_s("F")
  end
end
