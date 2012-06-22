require 'digest'
require 'json'
require 'mustacci/payload'

describe Mustacci::Payload do

  let(:payload_id) { Digest::MD5.hexdigest('payload_id') }
  let(:payload) { Mustacci::Payload.new(JSON.parse(File.read("spec/fixtures/payload.json")).merge(payload_id: payload_id)) }
  subject { payload }

  it "has a before" do
    payload.before.should == "5aef35982fb2d34e9d9d4502f6ede1072793222d"
  end

  it "has an after" do
    payload.after.should == "c7c302c80a6cbd12d2594885061df6d216fa4973"
  end

  it "has a ref" do
    payload.ref.should == "refs/heads/master"
  end

  it "has a payload id" do
    payload.payload_id.should == payload_id
  end

  it { should have(2).commits }

  describe "commits" do

    let(:commit) { payload.commits.first }

    it "has an id" do
      commit.id.should == "41a212ee83ca127e3c8cf465891ab7216a705f59"
    end

    it "has an url to github" do
      commit.url.should == "http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59"
    end

    it "has a message" do
      commit.message.should == "okay i give in"
    end

    it "has an author" do
      commit.author.email.should == "chris@ozmm.org"
      commit.author.name.should == "Chris Wanstrath"
    end

    it "has a timestamp" do
      commit.timestamp.should == Time.parse("2008-02-15T14:57:17-08:00")
    end

    it "has added files" do
      commit.added.should == ["filepath.rb"]
    end

  end

  describe "repository" do

    let(:repository) { payload.repository }

    it "has a url" do
      repository.url.should ==  "git@github.com:marceldegraaf/mustacci.git"
    end

    it "has a name" do
      repository.name.should == "github"
    end

    it "has a description" do
      repository.description.should == "You're lookin' at it."
    end

    it "has an owner" do
      repository.owner.email.should == "chris@ozmm.org"
      repository.owner.name.should == "defunkt"
    end

  end

end
