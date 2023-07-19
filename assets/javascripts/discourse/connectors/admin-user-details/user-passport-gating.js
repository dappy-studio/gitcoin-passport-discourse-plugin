import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import Component from "@glimmer/component";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import UserAction from "discourse/models/user-action";

export default class UserPassportGating extends Component {
  @service siteSettings;
  get isPassportEnabled() {
    return this.siteSettings.passport_enabled;
  }

  get username() {
    const { username } = this.args.outletArgs.model;
    return username;
  }

  get userId() {
    const { id } = this.args.outletArgs.model;
    return id;
  }

  get minScoreToPost() {
    return this.args.outletArgs.model.min_score_to_post || 0;
  }

  get minScoreToCreateTopic() {
    return this.args.outletArgs.model.min_score_to_create_topic || 0;
  }

  @action
  saveMinimumScoreToCreatePost(newScore) {
    let userId = this.userId;
    const oldScore = this.minScoreToPost;
    this.args.outletArgs.model.set("min_score_to_post", newScore);

    ajax({
      url: "/passport/saveUserScore",
      type: "PUT",
      data: {
        user_id: userId,
        action_id: UserAction.TYPES.posts,
        score: newScore,
      },
    })
      .catch((e) => {
        this.args.outletArgs.model.set("min_score_to_post", oldScore);
        popupAjaxError(e);
      })
      .finally(() => {
        this.args.outletArgs.model.toggleProperty(
          "editingMinimumScoreToCreatePost"
        );
      });
  }

  @action
  saveMinimumScoreToCreateTopic(newScore) {
    let userId = this.userId;
    const oldScore = this.minScoreToCreateTopic;
    this.args.outletArgs.model.set("min_score_to_create_topic", newScore);
    ajax({
      url: "/passport/saveUserScore",
      type: "PUT",
      data: {
        user_id: userId,
        action_id: UserAction.TYPES.topics,
        score: newScore,
      },
    })
      .catch((e) => {
        this.args.outletArgs.model.set("min_score_to_create_topic", oldScore);
        popupAjaxError(e);
      })
      .finally(() => {
        this.args.outletArgs.model.toggleProperty(
          "editingMinimumScoreToCreateTopic"
        );
      });
  }
}
