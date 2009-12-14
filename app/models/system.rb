class System < ActiveRecord::Base

  acts_as_paranoid
  NON_MEMBERS_ALLOW, NON_MEMBERS_DISALLOW = 0, 1
  BUYING_RULE_NAMES = { NON_MEMBERS_ALLOW => "非会員の購入を許可する", NON_MEMBERS_DISALLOW => "非会員の購入を許可しない" }
  MALE, FEMALE = 1, 2
  SEX_NAMES = { MALE => "男性", FEMALE => "女性" }

  # カタカナに一致する正規表現
  KATAKANA_PATTERN = /^(?:\xE3\x82[\xA1-\xBF]|\xE3\x83[\x80-\xB6\xBC])*$/

  def validate_on_create
    errors.add "","複数のデータは登録できません。"  if System.count > 0
  end
end
