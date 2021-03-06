require_relative '../../lib/converter/account_number_parser'
require_relative '../../lib/converter/account_number_interpreter'

describe AccountNumberInterpreter do
  let(:matrices) { AccountNumberParser.new(ocr_string).matrix }
  let(:interpreter) { described_class.new(matrices) }

  describe '#account_number' do
    subject { interpreter.account_number }
    context 'with a valid number' do
      let(:ocr_string) do
        " _                         \n" \
        "  |  |  |  |  |  |  |  |  |\n" \
        "  |  |  |  |  |  |  |  |  |\n"
      end
      it 'returns the valid account number' do
        expect(subject).to eq('711111111')
      end
    end
    context 'with an illegible number' do
      context 'that has one one correct permutation' do
        let(:ocr_string) do
          " _     _  _  _  _  _  _    \n" \
          "| || || || || || || ||_   |\n" \
          "|_||_||_||_||_||_||_| _|  |\n"
        end
        it 'returns the correct permutation' do
          expect(subject).to eq('000000051')
        end
      end
      context 'that has more than one correct permutation' do
        let(:ocr_string) do
          "    _     _  _  _  _     _ \n" \
          "|_||_|| || ||_   |  |  ||_ \n" \
          "  | _||_||_||_|  |  |  | _|\n"
        end
        it 'returns the account number with the illegible char' do
          expect(subject).to eq('49?067715')
        end
      end
      context 'that has no correct permutations' do
        let(:ocr_string) do
          " _  _     _   |       _  _ \n" \
          "|_ |_ |_| _|  |  ||_||_||_ \n" \
          "|_||_|  | _|  |  |  | _| _|\n"
        end
        it 'returns the account number with the illegible char' do
          expect(subject).to eq('6643?1495')
        end
      end
    end
    context 'with an erroneous number' do
      context 'that has one one correct permutation' do
        let(:ocr_string) do
          " _  _  _  _  _  _  _  _  _ \n" \
          "| || || || || || || ||_   |\n" \
          "|_||_||_||_||_||_||_| _|  |\n"
        end
        it 'returns the correct permutation' do
          expect(subject).to eq('000000051')
        end
      end
      context 'that has more than one correct permutation' do
        let(:ocr_string) do
          "    _  _  _  _  _  _     _ \n" \
          "|_||_|| || ||_   |  |  ||_ \n" \
          "  | _||_||_||_|  |  |  | _|\n"
        end
        it 'returns the account number with the illegible char' do
          expect(subject).to eq('490067715')
        end
      end
      context 'that has no correct permutations' do
        let(:ocr_string) do
          " _  _     _           _  _ \n" \
          "|_ |_ |_| _|  |  ||_||_||_ \n" \
          "|_||_|  | _|  |  |  | _| _|\n"
        end
        it 'returns the account number with the illegible char' do
          expect(subject).to eq('664311495')
        end
      end
    end
  end

  describe '#interpreted_account_number' do
    subject { interpreter.interpreted_account_number }
    context 'with one_to_nine.txt' do
      let(:ocr_string) { File.read('spec/fixtures/one_to_nine.txt') }
      it "yields '123456789'" do
        expect(subject).to eq('123456789')
      end
    end

    context 'with zero_to_nine.txt' do
      let(:ocr_string) { File.read('spec/fixtures/zero_to_nine.txt') }
      it "yields '0123456789'" do
        expect(subject).to eq('0123456789')
      end
    end

    context 'with nine_to_zero.txt' do
      let(:ocr_string) { File.read('spec/fixtures/nine_to_zero.txt') }
      it "yields '9876543210'" do
        expect(subject).to eq('9876543210')
      end
    end
  end

  describe '#possible_account_numbers' do
    subject { interpreter.possible_account_numbers }
    context 'when the account_number is 111111111' do
      let(:ocr_string) do
        "                           \n" \
        "  |  |  |  |  |  |  |  |  |\n" \
        "  |  |  |  |  |  |  |  |  |\n"
      end
      it 'corrects to 711111111' do
        expect(subject).to eq(['711111111'])
      end
    end


    context 'when the account_number is 777777777' do
      let(:ocr_string) do
        " _  _  _  _  _  _  _  _  _ \n" \
        "  |  |  |  |  |  |  |  |  |\n" \
        "  |  |  |  |  |  |  |  |  |\n"
      end
      it 'corrects to 777777177' do
        expect(subject).to eq(['777777177'])
      end
    end

    context 'when the account_number is 2000000000' do
      let(:ocr_string) do
        " _  _  _  _  _  _  _  _  _ \n" \
        " _|| || || || || || || || |\n" \
        "|_ |_||_||_||_||_||_||_||_|\n"
      end
      it 'corrects to 200800000' do
        expect(subject).to eq(['200800000'])
      end
    end
    context 'when the account_number is 333333333' do
      let(:ocr_string) do
        " _  _  _  _  _  _  _  _  _ \n" \
        " _| _| _| _| _| _| _| _| _|\n" \
        " _| _| _| _| _| _| _| _| _|\n"
      end
      it 'corrects to 333393333' do
        expect(subject).to eq(['333393333'])
      end
    end

    context 'when the account_number is 888888888' do
      let(:ocr_string) do
        " _  _  _  _  _  _  _  _  _ \n" \
        "|_||_||_||_||_||_||_||_||_|\n" \
        "|_||_||_||_||_||_||_||_||_|\n"
      end
      it 'specifies an ambiguous match' do
        expect(subject).to match_array(['888886888', '888888880', '888888988'])
      end
    end

    context 'when the account_number is 555555555' do
      let(:ocr_string) do
        " _  _  _  _  _  _  _  _  _ \n" \
        "|_ |_ |_ |_ |_ |_ |_ |_ |_ \n" \
        " _| _| _| _| _| _| _| _| _|\n"
      end
      it 'specifies an ambiguous match' do
        expect(subject).to match_array(['555655555', '559555555'])
      end
    end

    context 'when the account_number is 666666666' do
      let(:ocr_string) do
        " _  _  _  _  _  _  _  _  _ \n" \
        "|_ |_ |_ |_ |_ |_ |_ |_ |_ \n" \
        "|_||_||_||_||_||_||_||_||_|\n"
      end
      it 'specifies an ambiguous match' do
        expect(subject).to match_array(['666566666', '686666666'])
      end
    end

    context 'when the account_number is 999999999' do
      let(:ocr_string) do
        " _  _  _  _  _  _  _  _  _ \n" \
        "|_||_||_||_||_||_||_||_||_|\n" \
        " _| _| _| _| _| _| _| _| _|\n"
      end
      it 'specifies an ambiguous match' do
        expect(subject).to match_array(['899999999', '993999999', '999959999'])
      end
    end

    context 'when the account_number is 490067715' do
      let(:ocr_string) do
        "    _  _  _  _  _  _     _ \n" \
        "|_||_|| || ||_   |  |  ||_ \n" \
        "  | _||_||_||_|  |  |  | _|\n"
      end
      it 'specifies an ambiguous match' do
        expect(subject).to match_array(['490067115', '490067719', '490867715'])
      end
    end

    context 'when the account_number is ?23456789' do
      let(:ocr_string) do
        "    _  _     _  _  _  _  _ \n" \
        " _| _| _||_||_ |_   ||_||_|\n" \
        "  ||_  _|  | _||_|  ||_| _|\n"
      end
      it 'corrects an illegible number' do
        expect(subject).to eq(['123456789'])
      end
    end

    context 'when the account_number is 0?0000051' do
      let(:ocr_string) do
        " _     _  _  _  _  _  _    \n" \
        "| || || || || || || ||_   |\n" \
        "|_||_||_||_||_||_||_| _|  |\n"
      end
      it 'corrects an illegible number' do
        expect(subject).to eq(['000000051'])
      end
    end

    context 'when the account_number is 49086771?' do
      let(:ocr_string) do
        "    _  _  _  _  _  _     _ \n" \
        "|_||_|| ||_||_   |  |  | _ \n" \
        "  | _||_||_||_|  |  |  | _|\n"
      end
      it 'corrects an illegible number' do
        expect(subject).to eq(['490867715'])
      end
    end
  end

  describe '#error_description' do
    subject { interpreter.error_description }
    context 'when the account number is valid' do
      let(:ocr_string) do
        " _                         \n" \
        "  |  |  |  |  |  |  |  |  |\n" \
        "  |  |  |  |  |  |  |  |  |\n"
      end
      specify { expect(subject).to be(nil) }
    end

    context 'when the account number is invalid' do
      context 'and the account number is illegible' do
        context 'and there are no valid permutations' do
          let(:ocr_string) do
            " _  _     _   |       _  _ \n" \
            "|_ |_ |_| _|  |  ||_||_||_ \n" \
            "|_||_|  | _|  |  |  | _| _|\n"
          end
          specify { expect(subject).to eq(' ILL') }
        end
        context 'and there is one valid permutation' do
          let(:ocr_string) do
            "                           \n" \
            "  |  |  |  |  |  |  |  |  |\n" \
            "  |  |  |  |  |  |  |  |  |\n"
          end
          specify { expect(subject).to be(nil) }
        end
      end

      context 'and the account number is legible' do
        context 'and there is one valid permutation' do
          let(:ocr_string) do
            " _     _        _  _  _  _ \n" \
            "  |  |  |  ||_| _|  ||_|  |\n" \
            "  |  |  |  |  | _|  | _|  |\n"
          end
          specify { expect(subject).to be(nil) }
        end
        context 'and there is more than one one valid permutation' do
          let(:ocr_string) do
            "    _  _  _  _  _  _     _ \n" \
            "|_||_|| || ||_   |  |  ||_ \n" \
            "  | _||_||_||_|  |  |  | _|\n"
          end
          specify do
            expect(subject).to eq(" AMB [\"490867715\", \"490067115\", \"490067719\"]")
          end
        end
      end
    end
  end
end
