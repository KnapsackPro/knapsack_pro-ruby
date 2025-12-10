describe Meme do
  describe '#i_can_has_cheezburger?' do
    it do
      expect(subject.i_can_has_cheezburger?).to eq "OHAI!"
    end
  end

  describe '#will_it_blend?' do
    it do
      expect(subject.will_it_blend?).to eq "YES!"
    end
  end
end
