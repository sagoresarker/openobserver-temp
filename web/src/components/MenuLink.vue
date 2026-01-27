<!-- Copyright 2023 OpenObserve Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->

<template>
  <q-item
    :data-test="`menu-link-${link}-item`"
    v-ripple="true"
    :to="
      !external
        ? {
            path: link,
            exact: false,
            query: {
              org_identifier: store.state.selectedOrganization?.identifier,
            },
          }
        : ''
    "
    clickable
    :class="{
      'q-router-link--active':
        router.currentRoute.value.path.indexOf(link) == 0 && link != '/',
      'q-link-function': title == 'Functions',
    }"
    :target="target"
    :aria-current="isActive ? 'page' : undefined"
    :aria-label="ariaLabel"
    v-on="external ? { click: () => openWebPage(link) } : {}"
  >
    <q-item-section v-if="icon" avatar>
      <div class="icon-wrapper">
        <q-icon :name="icon" />
        <div
          v-if="badge && badge > 0"
          class="menu-badge"
          aria-live="polite"
          :aria-label="`${badge} notifications`"
        >
          {{ badge > 99 ? '99+' : badge }}
        </div>
      </div>
      <q-item-label>{{ title }}</q-item-label>
    </q-item-section>
    <q-item-section v-else-if="iconComponent" avatar>
      <div class="icon-wrapper">
        <q-icon><component :is="iconComponent" /></q-icon>
        <div
          v-if="badge && badge > 0"
          class="menu-badge"
          aria-live="polite"
          :aria-label="`${badge} notifications`"
        >
          {{ badge > 99 ? '99+' : badge }}
        </div>
      </div>
      <q-item-label>{{ title }}</q-item-label>
    </q-item-section>
  </q-item>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useStore } from "vuex";
import { useRouter } from "vue-router";

export default defineComponent({
  name: "MenuLink",
  props: {
    title: {
      type: String,
      required: true,
    },

    caption: {
      type: String,
      default: "",
    },

    link: {
      type: String,
      default: "#",
    },

    icon: {
      type: String,
      default: "",
    },

    iconComponent: {
      type: Object,
      default: () => ({}),
    },

    mini: {
      type: Boolean,
      default: true,
    },

    target: {
      type: String,
      default: "_self",
    },

    external: {
      type: Boolean,
      default: false,
    },

    // Phase 4: Badge support
    badge: {
      type: Number,
      default: 0,
    },
  },
  setup(props) {
    const store = useStore();
    const router: any = useRouter();

    const openWebPage = (url: string) => {
      window.open(url, "_blank");
    };

    // Phase 5: Accessibility - compute active state
    const isActive = computed(() => {
      return router.currentRoute.value.path.indexOf(props.link) === 0 && props.link !== '/';
    });

    // Phase 5: Accessibility - compute ARIA label with fallback
    const ariaLabel = computed(() => {
      let label = props.title || 'Navigation link';
      if (props.badge && props.badge > 0) {
        label += ` (${props.badge} notifications)`;
      }
      if (isActive.value) {
        label += ' - Current page';
      }
      return label;
    });

    return {
      store,
      router,
      openWebPage,
      isActive,
      ariaLabel,
    };
  },
});
</script>

<style scoped lang="scss">
.q-item {
  padding: 8px 12px;
  margin: 2px 8px;
  border-radius: 6px;
  border: none;
  min-height: 40px;
  transition: background-color 0.15s ease, color 0.15s ease;

  &:first-child {
    margin-top: 8px;
  }

  // Clean hover state
  &:hover:not(.q-router-link--active) {
    background-color: var(--platform-menu-hover-bg, var(--o2-hover-accent));
    
    .q-icon {
      color: var(--platform-menu-color, var(--o2-menu-color));
    }

    .q-item-label {
      color: var(--platform-menu-color, var(--o2-menu-color));
    }
  }

  // Clean active state - minimal, professional
  &.q-router-link--active {
    background-color: var(--platform-menu-active-bg, var(--o2-menu-gradient-start)) !important;
    position: relative;

    .q-icon {
      color: var(--platform-menu-active-color, var(--o2-primary-btn-bg)) !important;
    }

    .q-item-label {
      font-weight: 600;
      color: var(--platform-menu-active-color, var(--o2-primary-btn-bg)) !important;
    }

    // Clean left border indicator
    &::before {
      content: "";
      position: absolute;
      left: 0;
      top: 8px;
      bottom: 8px;
      width: 3px;
      background-color: var(--platform-menu-active-border, var(--o2-primary-btn-bg));
      border-radius: 0 2px 2px 0;
    }
  }

  // Focus state
  &:focus-visible {
    outline: 2px solid var(--platform-focus-ring, var(--o2-focus-ring));
    outline-offset: 2px;
  }

  &.ql-item-mini {
    margin: 2px 4px;
    
    &::before {
      display: none;
    }
  }
}

// Clean icon container
.q-item__section--avatar {
  margin: 0;
  padding: 0;
  min-width: 20px;
  margin-right: 12px;

  .q-icon {
    font-size: 18px;
    transition: color 0.15s ease;
    color: var(--platform-menu-color, var(--o2-menu-color));
  }
}

// Clean label
.q-item-label {
  font-size: 14px;
  font-weight: 400;
  line-height: 1.5;
  transition: color 0.15s ease, font-weight 0.15s ease;
  color: var(--platform-menu-color, var(--o2-menu-color));
}

// Badge - clean and minimal
.icon-wrapper {
  position: relative;
  display: inline-block;
}

.menu-badge {
  position: absolute;
  top: -6px;
  right: -8px;
  min-width: 18px;
  height: 18px;
  padding: 0 5px;
  background-color: var(--platform-danger, #cf222e);
  border: 2px solid var(--platform-card-bg, #ffffff);
  border-radius: 9px;
  font-size: 11px;
  font-weight: 600;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
  z-index: 1;
}

// Platform UI specific overrides for cleaner look
body.platform-ui {
  .q-item {
    margin: 1px 0;
    padding: 10px 16px;
    border-radius: 0;

    &:hover:not(.q-router-link--active) {
      background-color: var(--platform-menu-hover-bg);
    }

    &.q-router-link--active {
      background-color: var(--platform-menu-active-bg);
      
      &::before {
        width: 2px;
        top: 0;
        bottom: 0;
        border-radius: 0;
      }
    }
  }

  .q-item__section--avatar {
    min-width: 20px;
    margin-right: 12px;
  }

  .q-item-label {
    font-size: 14px;
  }
}

</style>
