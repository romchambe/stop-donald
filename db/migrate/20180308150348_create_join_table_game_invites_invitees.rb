class CreateJoinTableGameInvitesInvitees < ActiveRecord::Migration[5.1]
  def change
    create_join_table :game_invites, :invitees do |t|
      t.index [:game_invite_id, :invitee_id]
      t.index [:invitee_id, :game_invite_id]
    end
  end
end
