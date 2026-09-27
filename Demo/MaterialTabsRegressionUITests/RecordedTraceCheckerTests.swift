import XCTest

final class RecordedTraceCheckerTests: XCTestCase {
    private static let vectors = Result { try RegressionResources.json("checker-migration-controls").array }
    private static let plans = Result { try RegressionResources.json("query-free-cases") }

    override func setUpWithError() throws {
        continueAfterFailure = false
        RegressionRunObserver.install()
        try XCTSkipIf(RegressionRunObserver.precedingFailure != nil, "Stopped after earlier failure")
    }

    private func verify(_ name: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let vectors = try Self.vectors.get().filter { $0["test"].string == name }
        XCTAssertFalse(vectors.isEmpty, "No control vectors for \(name)", file: file, line: line)
        let checker = RecordedTraceChecker(plans: try Self.plans.get())
        for (index, vector) in vectors.enumerated() {
            if let failure = CheckerControlReplay.mismatch(vector, checker: checker) {
                XCTFail("\(name) input \(index): \(failure)", file: file, line: line)
            }
        }
    }
    func test_absent_evidence_is_inconclusive() throws { try verify("test_absent_evidence_is_inconclusive") }
    func test_actual_offset_not_requested_target() throws { try verify("test_actual_offset_not_requested_target") }
    func test_ambiguous_header_identity_fails() throws { try verify("test_ambiguous_header_identity_fails") }
    func test_ambiguous_short_scrolls_are_rejected() throws { try verify("test_ambiguous_short_scrolls_are_rejected") }
    func test_ambiguous_vertical_view_is_inconclusive() throws { try verify("test_ambiguous_vertical_view_is_inconclusive") }
    func test_bottom_requires_observed_range_overscroll_and_repeated_stop() throws { try verify("test_bottom_requires_observed_range_overscroll_and_repeated_stop") }
    func test_broad_initial_tab_is_checked() throws { try verify("test_broad_initial_tab_is_checked") }
    func test_broad_mode_is_checked() throws { try verify("test_broad_mode_is_checked") }
    func test_calibrated_ios17_viewport() throws { try verify("test_calibrated_ios17_viewport") }
    func test_calibrated_ios18_display_sampling() throws { try verify("test_calibrated_ios18_display_sampling") }
    func test_capture_cannot_substitute_a_different_plan() throws { try verify("test_capture_cannot_substitute_a_different_plan") }
    func test_content_spike_across_updates_cannot_be_hidden_by_recovery() throws { try verify("test_content_spike_across_updates_cannot_be_hidden_by_recovery") }
    func test_correct_context() throws { try verify("test_correct_context") }
    func test_correct_context_and_actual_position_pass_together() throws { try verify("test_correct_context_and_actual_position_pass_together") }
    func test_correct_context_cannot_hide_unmoved_scroll_view() throws { try verify("test_correct_context_cannot_hide_unmoved_scroll_view") }
    func test_deceleration_does_not_require_dragging_flag_to_be_false() throws { try verify("test_deceleration_does_not_require_dragging_flag_to_be_false") }
    func test_detached_scroll_is_observed_without_window_coordinates() throws { try verify("test_detached_scroll_is_observed_without_window_coordinates") }
    func test_disabled_recorder_is_not_a_pass() throws { try verify("test_disabled_recorder_is_not_a_pass") }
    func test_display_tick_cannot_claim_update_completion() throws { try verify("test_display_tick_cannot_claim_update_completion") }
    func test_display_tick_does_not_relabel_old_view_source_as_restored() throws { try verify("test_display_tick_does_not_relabel_old_view_source_as_restored") }
    func test_duplicate_visible_and_detached_identity_is_inconclusive() throws { try verify("test_duplicate_visible_and_detached_identity_is_inconclusive") }
    func test_explicit_display_tick_sampling() throws { try verify("test_explicit_display_tick_sampling") }
    func test_extended_header_dimensions_are_checked() throws { try verify("test_extended_header_dimensions_are_checked") }
    func test_extended_initial_selection_is_checked() throws { try verify("test_extended_initial_selection_is_checked") }
    func test_external_correct_row_cannot_hide_wrong_native_offset() throws { try verify("test_external_correct_row_cannot_hide_wrong_native_offset") }
    func test_external_item_requires_independent_row_alignment() throws { try verify("test_external_item_requires_independent_row_alignment") }
    func test_external_request_requires_callback_and_live_geometry() throws { try verify("test_external_request_requires_callback_and_live_geometry") }
    func test_first_wrong_restored_value_cannot_be_hidden_by_later_recovery() throws { try verify("test_first_wrong_restored_value_cannot_be_hidden_by_later_recovery") }
    func test_flick_requires_actual_post_lift_deceleration() throws { try verify("test_flick_requires_actual_post_lift_deceleration") }
    func test_forged_context_value_is_inconclusive() throws { try verify("test_forged_context_value_is_inconclusive") }
    func test_fresh_wrong_display_source_still_fails() throws { try verify("test_fresh_wrong_display_source_still_fails") }
    func test_fresh_wrong_update_input_still_fails() throws { try verify("test_fresh_wrong_update_input_still_fails") }
    func test_header_expansion_fails() throws { try verify("test_header_expansion_fails") }
    func test_header_is_checked_even_before_destination_synchronization() throws { try verify("test_header_is_checked_even_before_destination_synchronization") }
    func test_header_spike_across_updates_cannot_be_hidden_by_recovery() throws { try verify("test_header_spike_across_updates_cannot_be_hidden_by_recovery") }
    func test_held_drag_cannot_count_as_flick() throws { try verify("test_held_drag_cannot_count_as_flick") }
    func test_in_progress_animation_is_inconclusive() throws { try verify("test_in_progress_animation_is_inconclusive") }
    func test_initial_geometry_zero_is_not_selected_context() throws { try verify("test_initial_geometry_zero_is_not_selected_context") }
    func test_initial_native_pager_matches_requested_tab() throws { try verify("test_initial_native_pager_matches_requested_tab") }
    func test_insets_and_offscreen_views() throws { try verify("test_insets_and_offscreen_views") }
    func test_integrity_failures() throws { try verify("test_integrity_failures") }
    func test_ios17_cannot_claim_after_update_sampling() throws { try verify("test_ios17_cannot_claim_after_update_sampling") }
    func test_later_correct_page_cannot_repair_initial_mismatch() throws { try verify("test_later_correct_page_cannot_repair_initial_mismatch") }
    func test_missing_capture_is_inconclusive() throws { try verify("test_missing_capture_is_inconclusive") }
    func test_missing_destination_synchronization_is_inconclusive() throws { try verify("test_missing_destination_synchronization_is_inconclusive") }
    func test_missing_or_ambiguous_initial_pager_is_inconclusive() throws { try verify("test_missing_or_ambiguous_initial_pager_is_inconclusive") }
    func test_missing_or_unsettled_parked_page_is_inconclusive() throws { try verify("test_missing_or_unsettled_parked_page_is_inconclusive") }
    func test_missing_sample_at_boundary_is_inconclusive() throws { try verify("test_missing_sample_at_boundary_is_inconclusive") }
    func test_missing_selected_page_is_inconclusive() throws { try verify("test_missing_selected_page_is_inconclusive") }
    func test_missing_token_is_inconclusive() throws { try verify("test_missing_token_is_inconclusive") }
    func test_missing_transition_fails() throws { try verify("test_missing_transition_fails") }
    func test_native_geometry_mismatch_fails() throws { try verify("test_native_geometry_mismatch_fails") }
    func test_native_missing_header_is_inconclusive() throws { try verify("test_native_missing_header_is_inconclusive") }
    func test_native_never_scrolled_fails() throws { try verify("test_native_never_scrolled_fails") }
    func test_native_rest_scrolled_rest() throws { try verify("test_native_rest_scrolled_rest") }
    func test_no_boundaries_is_inconclusive_not_a_pass() throws { try verify("test_no_boundaries_is_inconclusive_not_a_pass") }
    func test_other_consumer_cannot_replace_header_context() throws { try verify("test_other_consumer_cannot_replace_header_context") }
    func test_other_modes_keep_relative_position_in_all_header_states() throws { try verify("test_other_modes_keep_relative_position_in_all_header_states") }
    func test_parked_position_is_observed_before_return() throws { try verify("test_parked_position_is_observed_before_return") }
    func test_profile_cannot_override_real_app_bounds() throws { try verify("test_profile_cannot_override_real_app_bounds") }
    func test_registration_copy_cannot_establish_destination_readiness() throws { try verify("test_registration_copy_cannot_establish_destination_readiness") }
    func test_registration_copy_is_excluded() throws { try verify("test_registration_copy_is_excluded") }
    func test_replaced_state_object_fails() throws { try verify("test_replaced_state_object_fails") }
    func test_replaced_state_value_fails() throws { try verify("test_replaced_state_value_fails") }
    func test_reset_position_contract_expanded_partial_and_collapsed() throws { try verify("test_reset_position_contract_expanded_partial_and_collapsed") }
    func test_reset_position_without_collapsible_title_keeps_position() throws { try verify("test_reset_position_without_collapsible_title_keeps_position") }
    func test_same_storage_survives_repeated_selection() throws { try verify("test_same_storage_survives_repeated_selection") }
    func test_saved_relative_offset_survives_header_change() throws { try verify("test_saved_relative_offset_survives_header_change") }
    func test_selection_requires_recent_active_deceleration() throws { try verify("test_selection_requires_recent_active_deceleration") }
    func test_short_fixture_cannot_silently_run_long_content() throws { try verify("test_short_fixture_cannot_silently_run_long_content") }
    func test_short_insets_contribute_to_scroll_range() throws { try verify("test_short_insets_contribute_to_scroll_range") }
    func test_source_context_can_complete_after_touch_down_before_action() throws { try verify("test_source_context_can_complete_after_touch_down_before_action") }
    func test_stale_capture_is_inconclusive() throws { try verify("test_stale_capture_is_inconclusive") }
    func test_stale_context_source_is_inconclusive() throws { try verify("test_stale_context_source_is_inconclusive") }
    func test_swipe_saves_source_before_prefetch_not_at_selection() throws { try verify("test_swipe_saves_source_before_prefetch_not_at_selection") }
    func test_sync_target_is_not_a_context_sample() throws { try verify("test_sync_target_is_not_a_context_sample") }
    func test_uncalibrated_tap_profile_is_inconclusive() throws { try verify("test_uncalibrated_tap_profile_is_inconclusive") }
    func test_unchanged_restoration_needs_no_new_onchange() throws { try verify("test_unchanged_restoration_needs_no_new_onchange") }
    func test_unchanged_update_input_needs_no_new_onchange() throws { try verify("test_unchanged_update_input_needs_no_new_onchange") }
    func test_unchanged_wrong_restoration_still_fails() throws { try verify("test_unchanged_wrong_restoration_still_fails") }
    func test_unchanged_wrong_update_input_still_fails() throws { try verify("test_unchanged_wrong_update_input_still_fails") }
    func test_unconsumed_raw_mutation_is_not_a_completed_context() throws { try verify("test_unconsumed_raw_mutation_is_not_a_completed_context") }
    func test_unknown_sampling_is_inconclusive() throws { try verify("test_unknown_sampling_is_inconclusive") }
    func test_update_completion_does_not_relabel_old_view_source_as_restored() throws { try verify("test_update_completion_does_not_relabel_old_view_source_as_restored") }
    func test_update_completion_without_fresh_source_is_inconclusive() throws { try verify("test_update_completion_without_fresh_source_is_inconclusive") }
    func test_wrong_content_context_fails() throws { try verify("test_wrong_content_context_fails") }
    func test_wrong_header_setup_fails() throws { try verify("test_wrong_header_setup_fails") }
    func test_wrong_horizontal_destination_fails() throws { try verify("test_wrong_horizontal_destination_fails") }
    func test_wrong_initial_native_page_rejects_launch_setup() throws { try verify("test_wrong_initial_native_page_rejects_launch_setup") }
    func test_wrong_selected_tab_fails() throws { try verify("test_wrong_selected_tab_fails") }
    func test_wrong_viewport_fails() throws { try verify("test_wrong_viewport_fails") }
}

