import { acceptance, query } from "discourse/tests/helpers/qunit-helpers";
import { click, settled, visit } from "@ember/test-helpers";
import { test } from "qunit";
import I18n from "I18n";

acceptance(
  "Acceptance | Passport Gating Banner | Past last date | User doesnt satisfy requirement after last date and needs to connect wallet",
  function (needs) {
    needs.settings({
      gitcoin_passport_enabled: true,
      gitcoin_passport_last_date_to_connect_wallet_for_existing_users:
        "2020-01-01",
      gitcoin_passport_forum_level_score_to_create_account: 10,
    });

    needs.user();

    test("shows the banner and asks user to connect wallet", async function (assert) {
      await visit("/");

      assert.ok(
        query(".passport-banner"),
        "it shows the passport gating banner"
      );
      assert.strictEqual(
        query(".banner-message").innerText.trim(),
        I18n.t("gitcoin_passport.banner.active_gating_not_connected_wallet"),
        "it should show the correct banner message"
      );
      assert.strictEqual(
        query(".passport-banner button").innerText.trim(),
        I18n.t("gitcoin_passport.banner.link_to_connect_wallet"),
        "it should show the correct link text"
      );
      assert.notOk(
        query(".score-required-to-post p"),
        "it should not show the minimum score required to post"
      );
      assert.notOk(
        query(".score-required-to-create-topic p"),
        "it should not show the minimum score required to create topic"
      );
      assert.notOk(
        query(".score-required-to-create-account p"),
        "it should not show the minimum score required to create account"
      );
      assert.notOk(
        query(".last-date p"),
        "it should not show the last date to connect wallet"
      );
    });
  }
);

acceptance(
  "Acceptance | Passport Gating Banner | Past last date | User doesnt satisfy requirement after last date and needs to increase score",
  function (needs) {
    needs.settings({
      gitcoin_passport_enabled: true,
      gitcoin_passport_last_date_to_connect_wallet_for_existing_users:
        "2020-01-01",
      gitcoin_passport_forum_level_score_to_create_account: 10,
    });

    needs.user({
      passport_score: 9,
      ethaddress: "0x123",
    });

    test("shows the banner along with the user score and minimum required score to create account but doesnt show anything else", async function (assert) {
      await visit("/");

      assert.ok(
        query(".passport-banner"),
        "it shows the passport gating banner"
      );
      assert.strictEqual(
        query(".banner-message").innerText.trim(),
        I18n.t("gitcoin_passport.banner.active_gating_low_score"),
        "it should show the correct banner message"
      );
      assert.strictEqual(
        query(".score-required-to-create-account p").innerText.trim(),
        "Minimum score required is 10",
        "it should show the minimum score required to create account"
      );
      assert.strictEqual(
        query(".user-score p").innerText.trim(),
        "Your current score is 9",
        "it should show the user score"
      );
      assert.notOk(
        query(".score-required-to-post p"),
        "it should not show the minimum score required to post"
      );
      assert.notOk(
        query(".score-required-to-create-topic p"),
        "it should not show the minimum score required to create topic"
      );
      assert.notOk(
        query(".last-date p"),
        "it should not show the last date to connect wallet"
      );
    });
  }
);

acceptance(
  "Acceptance | Passport Gating Banner | Past last date | User doesnt satisfy requirement before last date and needs to connect wallet",
  function (needs) {
    needs.settings({
      gitcoin_passport_enabled: true,
      gitcoin_passport_last_date_to_connect_wallet_for_existing_users:
        "2049-01-01",
      gitcoin_passport_forum_level_score_to_create_account: 10,
    });

    needs.user();

    test("shows the banner and asks user to connect wallet", async function (assert) {
      await visit("/");

      assert.ok(
        query(".passport-banner"),
        "it shows the passport gating banner"
      );
      assert.strictEqual(
        query(".banner-message").innerText.trim(),
        I18n.t("gitcoin_passport.banner.inactive_gating_not_connected_wallet"),
        "it should show the correct banner message"
      );
      assert.strictEqual(
        query(".passport-banner button").innerText.trim(),
        I18n.t("gitcoin_passport.banner.link_to_connect_wallet"),
        "it should show the correct link text"
      );
      assert.notOk(
        query(".score-required-to-post p"),
        "it should not show the minimum score required to post"
      );
      assert.notOk(
        query(".score-required-to-create-topic p"),
        "it should not show the minimum score required to create topic"
      );
      assert.notOk(
        query(".score-required-to-create-account p"),
        "it should not show the minimum score required to create account"
      );
      assert.strictEqual(
        query(".last-date p").innerText.trim(),
        "Gating starts on 2049-01-01",
        "it should show the last date to connect wallet"
      );
    });
  }
);

acceptance(
  "Acceptance | Passport Gating Banner | Past last date | User doesnt satisfy requirement before last date and needs to increase score",
  function (needs) {
    needs.settings({
      gitcoin_passport_enabled: true,
      gitcoin_passport_last_date_to_connect_wallet_for_existing_users:
        "2049-01-01",
      gitcoin_passport_forum_level_score_to_create_account: 10,
    });

    needs.user({
      passport_score: 9,
      ethaddress: "0x123",
    });

    test("shows the banner along with the user score and minimum required score to create account but doesnt show anything else", async function (assert) {
      await visit("/");

      assert.ok(
        query(".passport-banner"),
        "it shows the passport gating banner"
      );
      assert.strictEqual(
        query(".banner-message").innerText.trim(),
        I18n.t("gitcoin_passport.banner.inactive_gating_low_score"),
        "it should show the correct banner message"
      );
      assert.strictEqual(
        query(".score-required-to-create-account p").innerText.trim(),
        "Minimum score required is 10",
        "it should show the minimum score required to create account"
      );
      assert.strictEqual(
        query(".user-score p").innerText.trim(),
        "Your current score is 9",
        "it should show the user score"
      );
      assert.notOk(
        query(".score-required-to-post p"),
        "it should not show the minimum score required to post"
      );
      assert.notOk(
        query(".score-required-to-create-topic p"),
        "it should not show the minimum score required to create topic"
      );
      assert.strictEqual(
        query(".last-date p").innerText.trim(),
        "Gating starts on 2049-01-01",
        "it should show the last date to connect wallet"
      );
    });
  }
);

acceptance(
  "Acceptance | Passport Gating Banner | Past last date | User satisfies requirements",
  function (needs) {
    needs.settings({
      gitcoin_passport_enabled: true,
      gitcoin_passport_last_date_to_connect_wallet_for_existing_users:
        "2049-01-01",
      gitcoin_passport_forum_level_score_to_create_account: 10,
    });

    needs.user({
      passport_score: 11,
      ethaddress: "0x123",
    });

    test("shows the banner and asks user to connect wallet", async function (assert) {
      await visit("/");

      assert.notOk(
        query(".passport-banner"),
        "it should not show the passport gating banner"
      );
    });
  }
);

acceptance(
  "Acceptance | Passport Gating Banner | Past last date | Gitcoin Passport plugin is not enabled",
  function (needs) {
    needs.settings({
      gitcoin_passport_enabled: false,
      gitcoin_passport_last_date_to_connect_wallet_for_existing_users:
        "2049-01-01",
      gitcoin_passport_forum_level_score_to_create_account: 10,
    });

    needs.user();

    test("shows the banner and asks user to connect wallet", async function (assert) {
      await visit("/");

      assert.notOk(
        query(".passport-banner"),
        "it should not show the passport gating banner"
      );
    });
  }
);
