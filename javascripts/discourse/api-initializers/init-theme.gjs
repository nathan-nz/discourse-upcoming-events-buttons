import { apiInitializer } from "discourse/lib/api";
import I18n from "I18n";

export default apiInitializer((api) => {
  function iconMarkup(icon) {
    if (!icon?.trim()) {
      return "";
    }

    const iconName = icon.trim();

    return `
      <span class="icon" style="margin-right: 0.4em;" aria-hidden="true">
        <svg class="fa d-icon d-icon-${iconName} svg-icon" width="1em" height="1em">
          <use href="#${iconName}"></use>
        </svg>
      </span>
    `;
  }

  function makeButton({ className, title, label, icon, href }) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = `${className} fc-button fc-button-primary`;
    btn.title = title;
    btn.innerHTML = `${iconMarkup(icon)}${label}`;
    btn.addEventListener("click", () => {
      window.location.href = href;
    });
    return btn;
  }

  function addCustomButtons() {
    const toolbar = document.querySelector(".fc-allEvents-button")?.parentElement;
    if (!toolbar) return;

    const myEventsBtn = toolbar.querySelector(".fc-mineEvents-button");
    if (!myEventsBtn) return;

    if (settings.show_subscribe_button && !toolbar.querySelector(".fc-subscribe-button")) {
      const subscribeBtn = makeButton({
        className: "fc-subscribe-button",
        title: I18n.t(themePrefix("buttons.subscribe_title")),
        label: I18n.t(themePrefix("buttons.subscribe_label")),
        icon: settings.subscribe_button_icon,
        href: "/my/preferences/calendar-subscriptions",
      });

      myEventsBtn.after(subscribeBtn);
    }

    const newEventUrl = settings.new_event_url?.trim();

    if (newEventUrl && !toolbar.querySelector(".fc-newEvent-button")) {
      const newEventBtn = makeButton({
        className: "fc-newEvent-button",
        title: I18n.t(themePrefix("buttons.new_event_title")),
        label: I18n.t(themePrefix("buttons.new_event_label")),
        icon: settings.new_event_button_icon,
        href: newEventUrl,
      });

      const subscribeBtn = toolbar.querySelector(".fc-subscribe-button");
      if (subscribeBtn) {
        subscribeBtn.after(newEventBtn);
      } else {
        myEventsBtn.after(newEventBtn);
      }
    }
  }

  function scheduleButtonInsertion() {
    addCustomButtons();
    setTimeout(addCustomButtons, 300);
    setTimeout(addCustomButtons, 800);
  }

  api.onPageChange(() => {
    const router = api.container.lookup("service:router");
    const routeName = router.currentRouteName;

    if (!routeName?.startsWith("discourse-post-event-upcoming-events")) return;

    scheduleButtonInsertion();
  });
});
