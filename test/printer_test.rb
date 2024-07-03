require 'test_helper'

class PrinterTest < Minitest::Test
  context 'printing methods' do
    setup do 
      @data = {"users"=>
        {:count=>2,
         :location=>
          {nil=>{:count=>2, :sql=>"SELECT \"users\".* FROM \"users\" WHERE \"users\".\"email\" = $1 LIMIT $2"}}}}
    end
  
    should 'print html output without errors' do
      Launchy.expects(:open).with(anything).once
      QueryCounter::Printer::Html.print(@data)
    end

        
    should 'print console output without errors' do
      QueryCounter::Printer::Console.print(@data)
    end
  end
end
