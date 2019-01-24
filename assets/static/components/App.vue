<template>
	<body class="m-page--fluid m--skin- m-content--skin-light2 m-header--fixed m-header--fixed-mobile m-aside-left--enabled m-aside-left--skin-dark m-aside-left--offcanvas m-footer--push m-aside--offcanvas-default"  id="app">
    <!-- begin:: Page -->
        <div class="m-grid m-grid--hor m-grid--root m-page" id="page_content_main">
            <!-- BEGIN: Header -->
            <header class="m-grid__item m-header custom_header"  data-minimize-offset="200" data-minimize-mobile-offset="200" >
				<div class="m-container m-container--fluid m-container--full-height">
				    <div class="m-stack m-stack--ver m-stack--desktop">
				        <!-- BEGIN: Brand -->
				        <div class="m-stack__item m-brand  m-brand--skin-dark ">
				            <div class="m-stack m-stack--ver m-stack--general">
								<div class="menu_head">
									<div class="m-stack__item m-stack__item--middle m-brand__logo">
										<a href="javascript:;" class="m-brand__logo-wrapper menu_collapse">
											<img alt="" src="https://app.edgecommander.com/assets/demo/default/media/img/logo/logo_default_dark.png" />
										</a>
									</div>
								</div>
				                <div class="m-stack__item m-stack__item--middle m-brand__tools">
									<a href="javascript:;" class="menu_expand">
									<img alt="" src="https://app.edgecommander.com/images/fav-icons/favicon-32x32.png" style="margin: 0 20px;" />
									</a>
				                    <!-- END -->
				                    <!-- BEGIN: Responsive Aside Left Menu Toggler -->
				                    <a href="javascript:;" id="m_aside_left_offcanvas_toggle" class="m-brand__icon m-brand__toggler m-brand__toggler--left m--visible-tablet-and-mobile-inline-block">
				                        <span></span>
				                    </a>
				                    <!-- END -->
				                </div>
				            </div>
				        </div>
				        <!-- END: Brand -->
				        <div class="m-stack__item m-stack__item--fluid m-header-head" id="m_header_nav">
				            <!-- BEGIN: Horizontal Menu -->
				            <button class="m-aside-header-menu-mobile-close  m-aside-header-menu-mobile-close--skin-dark " id="m_aside_header_menu_mobile_close_btn">
				                <i class="la la-close"></i>
				            </button>
				            <!-- END: Horizontal Menu -->
				            <!-- BEGIN: Topbar -->
				            <div id="m_header_topbar" class="m-topbar  m-stack m-stack--ver m-stack--general">
				                <div class="m-stack__item m-topbar__nav-wrapper">
				                </div>
				            </div>
				            <!-- END: Topbar -->
				        </div>
				    </div>
				</div>
			</header>
            <!-- END: Header -->
            <!-- begin::Body -->
            <div class="m-grid__item m-grid__item--fluid m-grid m-grid--ver-desktop m-grid--desktop m-body">
                <!-- BEGIN: Left Aside -->
                <button class="m-aside-left-close  m-aside-left-close--skin-dark " id="m_aside_left_close_btn">
				    <i class="la la-close"></i>
				</button>
				<div id="m_aside_left" class="m-grid__item  m-aside-left  m-aside-left--skin-dark ">
				  <!-- BEGIN: Aside Menu -->
				  <div id="m_ver_menu" class="m-aside-menu  m-aside-menu--skin-dark  m-aside-menu--submenu-skin-dark " data-menu-vertical="true" data-menu-scrollable="false" data-menu-dropdown-timeout="500">
				     <ul class="m-menu__nav  m-menu__nav--dropdown-submenu-arrow ">
				         <li class="m-menu__item vue_links dashboard" aria-haspopup="true">
							<router-link v-bind:to="'/dashboard'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-dashboard m-menu__link-text"></i>
								<span class="m-menu__link-text">Dashboard</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links sims" aria-haspopup="true">
							<router-link v-bind:to="'/sims'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-newspaper-o m-menu__link-text"></i>
								<span class="m-menu__link-text">SIMs</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links nvrs" aria-haspopup="true">
							<router-link v-bind:to="'/nvrs'" class="m-menu__link">
								<i class="m-menu__link-icon la  la-building m-menu__link-text"></i>
								<span class="m-menu__link-text">NVRs</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links status_report" aria-haspopup="true">
							<router-link v-bind:to="'/status_report'" class="m-menu__link">
								<i class="m-menu__link-icon fa  fa-barcode m-menu__link-text"></i>
								<span class="m-menu__link-text">Status Report</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links routers" aria-haspopup="true">
							<router-link v-bind:to="'/routers'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-registered m-menu__link-text"></i>
								<span class="m-menu__link-text">Routers</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links sites" aria-haspopup="true">
							<router-link v-bind:to="'/sites'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-registered m-menu__link-text"></i>
								<span class="m-menu__link-text">Sites</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links commands" aria-haspopup="true">
							<router-link v-bind:to="'/commands'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-bullhorn m-menu__link-text"></i>
								<span class="m-menu__link-text">Commands</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links messages" aria-haspopup="true">
							<router-link v-bind:to="'/messages'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-envelope-open m-menu__link-text"></i>
								<span class="m-menu__link-text">Messages</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links batteries" aria-haspopup="true">
							<router-link v-bind:to="'/batteries'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-battery-full m-menu__link-text"></i>
								<span class="m-menu__link-text">Batteries</span>
							</router-link>
				        </li>
				    </ul>
				    <ul class="m-menu__nav  m-menu__nav--dropdown-submenu-arrow bottom_links">
						<li class="m-menu__item vue_links api" aria-haspopup="true">
							<router-link v-bind:to="'/api'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-paperclip m-menu__link-text"></i>
								<span class="m-menu__link-text">API</span>
							</router-link>
				        </li>
				        <li class="m-menu__item vue_links settings" aria-haspopup="true">
							<router-link v-bind:to="'/settings'" class="m-menu__link">
								<i class="m-menu__link-icon fa fa-gear m-menu__link-text"></i>
								<span class="m-menu__link-text">Settings</span>
							</router-link>
				        </li>
				        <li class="m-menu__item bottom_link" aria-haspopup="true" style="border-top: solid 1px #333333;">
				            <a  href="/users/session" class="m-menu__link ">
				                <i class="m-menu__link-icon fa fa-power-off"></i>
				                <span class="m-menu__link-title">
				                    <span class="m-menu__link-wrap">
				                        <span class="m-menu__link-text">
				                            Logout
				                        </span>
				                    </span>
				                </span>
				            </a>
				        </li>
				    </ul>
				  </div>
				  <!-- END: Aside Menu -->
				</div>
                <!-- END: Left Aside -->
                <div class="m-grid__item m-grid__item--fluid m-wrapper content_right_panel" id="remote_data">
					<notifications group="notify" />
					<router-view></router-view>
                </div>
            </div>
        </div>
            <!-- end:: Body -->
        <!-- begin::Scroll Top -->
        <div class="m-scroll-top m-scroll-top--skin-top" data-toggle="m-scroll-top" data-scroll-offset="500" data-scroll-speed="300">
            <i class="la la-arrow-up"></i>
        </div>
        <!-- end::Scroll Top -->
    </div>
    <!-- end:: Page -->
</body>
</template>

<script>
export default {
  name: 'app'
}
</script>



<style lang="scss">
@import '../css/app.scss';
</style>
