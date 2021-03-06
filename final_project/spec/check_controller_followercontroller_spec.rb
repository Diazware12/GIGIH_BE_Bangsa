require_relative '../controller/followerController'
require_relative '../model/liketweet'
require_relative '../model/follower'
require_relative '../db/db_connector'
require 'mysql2'
require 'json'

describe FollowerController do
  describe 'follow' do
    context 'when executed' do
      it 'should follow user' do
        stub = double
        controller = FollowerController.new

        params = {
          'userId' => 1,
          'userFollowersId' => 2
        }

        expect(Follower).to receive(:new).with(params).and_return(stub)
        expect(stub).to receive(:save)

        controller.follow(params)

        expect(Follower).to receive(:getFollowerData).with(1, 2).and_return(stub)
        result_item = Follower.getFollowerData(1, 2)
        expect(result_item).not_to be_nil
      end
    end

    context 'when executed API' do
      it 'should follow user' do
        stub = double
        controller = FollowerController.new

        params = {
          'userId' => 1,
          'userFollowersId' => 3
        }
        expect(Follower).to receive(:new).with(params).and_return(stub)
        expect(stub).to receive(:save)

        response = {
          "message": "Success",
          "status": 200,
          "method": "POST",
          "data": params
        }

        result = controller.follow_API(params)
        expect(result.to_json).to eq(response.to_json)
      end
    end
  end

  describe 'unfollow' do
    context 'when executed' do
      it 'should unfollow user' do
        stub = double
        controller = FollowerController.new

        params = {
          'userId' => 1,
          'userFollowersId' => 2
        }

        followerData = Follower.new(
          followersId: 1,
          userId: 1,
          userFollowersId: 2,
          dtm_crt: '2020-12-23'
        )

        stub_query = 'delete from followers where followersId = 1'
        allow(Mysql2::Client).to receive(:new).and_return(stub)
        expect(Follower).to receive(:getFollowerData).with(1, 2).and_return(followerData)
        expect(stub).to receive(:query).with(stub_query)
        expect(Follower).to receive(:getFollowerData).with(1, 2).and_return(nil)

        controller.unfollow(params)

        result = Follower.getFollowerData(1, 2)

        expect(result).to be_nil
      end
    end
    context 'when executed API' do
      it 'shouldn\'t unfollow user' do
        stub = double
        controller = FollowerController.new

        params = {
          'userId' => 1,
          'userFollowersId' => 2
        }

        response = {
          "message": "you're not followed this user before",
          "status": 401,
          "method": "POST",
          "data": params
        }

        expect(Follower).to receive(:getFollowerData).with(1, 2)

        result = controller.unfollow_API(params)
        expect(result.to_json).to eq(response.to_json)
      end
    end
  end
end
