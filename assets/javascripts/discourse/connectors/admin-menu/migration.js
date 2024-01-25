export default class PassportGatingBanner extends Component {
  @service siteSettings;
  @service currentUser;
  migrating = false;

  @action
  migrate() {
    console.log("migrate");
    this.set("migrating", true);
    ajax({
      url: "/passport/startMigration",
      type: "POST",
    })
      .catch((e) => {
        popupAjaxError(e);
      })
      .finally(() => {
        this.set("migrating", false);
      });
  }
}
