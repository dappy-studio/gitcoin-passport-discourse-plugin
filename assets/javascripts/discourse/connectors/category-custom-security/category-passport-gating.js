import { tagName } from "@ember-decorators/component";
import Component from "@ember/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import UserAction from "discourse/models/user-action";

@tagName("")
export default class CategoryPassportGating extends Component {
  @service siteSettings;
  editingMinimumScoreToCreatePost = false;
  editingMinimumScoreToCreateTopic = false;

  get category_id() {
    const { id } = this.attrs.outletArgs.value.category;
    return id;
  }

  get minScoreToPost() {
    return this.attrs.outletArgs.value.category.min_score_to_post || 0;
  }

  get minScoreToCreateTopic() {
    return this.attrs.outletArgs.value.category.min_score_to_create_topic || 0;
  }

  @action
  saveMinimumScoreToCreatePost(newScore) {
    let categoryId = this.category_id;
    const oldScore = this.minScoreToPost;
    this.attrs.outletArgs.value.category.set("min_score_to_post", newScore);

    ajax({
      url: "/passport/saveCategoryScore",
      type: "PUT",
      data: {
        category_id: categoryId,
        action_id: UserAction.TYPES.posts,
        score: newScore,
      },
    })
      .catch((e) => {
        this.attrs.outletArgs.value.category.set("min_score_to_post", oldScore);
        popupAjaxError(e);
      })
      .finally(() => {
        this.set("editingMinimumScoreToCreatePost", false);
      });
  }

  @action
  saveMinimumScoreToCreateTopic(newScore) {
    let categoryId = this.category_id;
    const oldScore = this.minScoreToCreateTopic;
    this.attrs.outletArgs.value.category.set(
      "min_score_to_create_topic",
      newScore
    );
    ajax({
      url: "/passport/saveCategoryScore",
      type: "PUT",
      data: {
        category_id: categoryId,
        action_id: UserAction.TYPES.topics,
        score: newScore,
      },
    })
      .catch((e) => {
        this.attrs.outletArgs.value.category.set(
          "min_score_to_create_topic",
          oldScore
        );
        popupAjaxError(e);
      })
      .finally(() => {
        this.set("editingMinimumScoreToCreateTopic", false);
      });
  }
}
