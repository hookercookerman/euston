describe 'event source historical versioning', :golf do
  context 'a new event source generates a commit' do
    let(:command) { namespace::BookTee.v(1).new(course_id: course_id, player_id: player_id, time: time).to_hash }

    before  { starter.consume command }

    subject { @commit }

    its(:sequence) { should == 1 }
  end

  context 'an event source that has already generated 1 commit receives another command' do
    let(:history) do
      commit = Euston::Commit.new nil, 1, [
        namespace::TeeBooked.v(1).new(course_id: course_id, player_id: player_id, time: time).to_hash
      ]

      Euston::EventSourceHistory.new commits: [ commit ]
    end

    let(:command) { namespace::CancelTeeBooking.v(1).new(course_id: course_id, player_id: player_id, time: time).to_hash }

    before  { starter(history).consume command }

    subject { @commit }

    its(:sequence) { should == 2 }
  end
end