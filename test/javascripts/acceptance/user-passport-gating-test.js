import {
  acceptance,
  exists,
  query,
} from "discourse/tests/helpers/qunit-helpers";
import { click, fillIn, visit } from "@ember/test-helpers";
import { test } from "qunit";

acceptance("Acceptance | User Passport Score Requirements", function (needs) {
  needs.settings({
    gitcoin_passport_enabled: true,
  });
  needs.pretender((server, helper) => {
    server.put("/passport/saveUserScore", () => helper.response(200, {}));
  });
  needs.user();

  test("can edit score required to post", async function (assert) {
    await visit("/admin/users/1/adityach4u");

    assert.ok(
      exists(".display-row.min-score-to-post"),
      "it shows the passport gating component"
    );
    assert.strictEqual(
      query(".display-row.min-score-to-post .value").innerText.trim(),
      "",
      "it should not show a score"
    );

    await click(".display-row.min-score-to-post button");
    await fillIn(".display-row.min-score-to-post .value input", "10");
    await click(".display-row.min-score-to-post a");
    assert.strictEqual(
      query(".display-row.min-score-to-post .value").innerText.trim(),
      "",
      "it should not save the score"
    );

    // Doing edit.
    await click(".display-row.min-score-to-post button");
    await fillIn(".display-row.min-score-to-post .value input", "10");
    await click(".display-row.min-score-to-post button");
    assert.strictEqual(
      query(".display-row.min-score-to-post .value").innerText.trim(),
      "10",
      "it should save the score"
    );
  });

  test("can edit score required to create topic", async function (assert) {
    await visit("/admin/users/1/adityach4u");

    assert.ok(
      exists(".display-row.min-score-to-create-topic"),
      "it shows the passport gating component"
    );
    assert.strictEqual(
      query(".display-row.min-score-to-create-topic .value").innerText.trim(),
      "",
      "it should not show a score"
    );

    await click(".display-row.min-score-to-create-topic button");
    await fillIn(".display-row.min-score-to-create-topic .value input", "10");
    await click(".display-row.min-score-to-create-topic a");
    assert.strictEqual(
      query(".display-row.min-score-to-create-topic .value").innerText.trim(),
      "",
      "it should not save the score"
    );

    // Doing edit.
    await click(".display-row.min-score-to-create-topic button");
    await fillIn(".display-row.min-score-to-create-topic .value input", "10");
    await click(".display-row.min-score-to-create-topic button");
    assert.strictEqual(
      query(".display-row.min-score-to-create-topic .value").innerText.trim(),
      "10",
      "it should save the score"
    );
  });
});
