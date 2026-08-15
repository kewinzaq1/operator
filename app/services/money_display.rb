class MoneyDisplay
  SYMBOLS = {
    "pln" => "zł",
    "eur" => "€",
    "usd" => "$",
    "gbp" => "£"
  }.freeze

  def self.call(amount, currency = "pln")
    code = currency.to_s.downcase
    symbol = SYMBOLS.fetch(code, code.upcase)
    number = format("%.0f", amount.to_f)
    if code == "pln"
      "#{number} #{symbol}"
    else
      "#{symbol}#{number}"
    end
  end
end
