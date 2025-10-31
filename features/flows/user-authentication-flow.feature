Feature: User Authentication Flow with Password Reset and Account Lockout
  As a security-aware application
  I want to authenticate users with robust security measures
  So that user accounts are protected while maintaining usability

@flow:context
Background: User Authentication Context
  Given the workflow engine is initialized
  And the MCP tool registry is available
  And the authentication context is empty
  And all required tools are configured
  And user database is accessible
  And password policy engine is enabled
  And account lockout system is operational
  And email notification service is available
  And audit logging system is active
  And session management is configured

@flow:decision_node
@scenario_id:login-attempt
@context:authentication_validation,security_checks
Scenario Outline: Process User Login Attempt
  Given user provides username <input:state.username>
  And password attempt is <input:state.password_attempt>
  And current failed attempts count is <input:state.failed_attempts>
  And account status is <input:state.account_status>
  And login source is <input:state.login_source>
  When the authentication system validates credentials
  Then it should execute tool <mcp_tool:name>
  And set authentication result to <output:state.auth_result>
  And update attempt counter to <output:state.attempt_counter>
  And set security level to <output:state.security_level>
  And record login timestamp as <output:state.login_timestamp>
  And transition to <transition>

  Examples: Login attempt decision table
    | input:state.username | input:state.password_attempt | input:state.failed_attempts | input:state.account_status | input:state.login_source | mcp_tool:name | mcp_tool:output_sample | output:state.auth_result | output:state.attempt_counter | output:state.security_level | output:state.login_timestamp | probability | transition |
    | state.username | "correct_password" | state.failed_attempts < 3 | active | trusted_device | semantic_search | {"auth_success": true, "user_id": "usr_123", "session_token": "sess_abc", "mfa_required": false} | "authentication_successful" | 0 | "standard" | new Date().toISOString() | 1.0 | successful-login |
    | state.username | "incorrect_password" | state.failed_attempts < 2 | active | state.login_source | file_search | {"auth_failed": true, "reason": "invalid_password", "attempts_remaining": 1, "lockout_warning": true} | "authentication_failed" | state.failed_attempts + 1 | "elevated" | current_timestamp | 0.9 | failed-attempt |
    | state.username | state.password_attempt | state.failed_attempts >= 3 | active | state.login_source | run_in_terminal | {"account_locked": true, "lockout_duration": "30min", "unlock_time": "2025-11-01T11:00:00Z", "security_alert": true} | "account_locked" | state.failed_attempts + 1 | "high" | lockout_timestamp | 1.0 | account-lockout |
    | state.username | state.password_attempt | state.failed_attempts | suspended | state.login_source | create_file | {"auth_blocked": true, "reason": "account_suspended", "contact_support": true, "incident_id": "INC-001"} | "account_suspended" | state.failed_attempts | "critical" | suspension_timestamp | 1.0 | account-suspended |
    | state.username | "correct_password" | state.failed_attempts < 3 | active | untrusted_device | semantic_search | {"auth_success": true, "mfa_required": true, "challenge_type": "sms", "session_pending": true} | "mfa_required" | 0 | "enhanced" | mfa_timestamp | 1.0 | mfa-challenge |
    | state.username | state.password_attempt | state.failed_attempts | locked | state.login_source | file_search | {"account_locked": true, "lockout_remaining": "25min", "unlock_time": "2025-11-01T11:00:00Z", "admin_contact": true} | "account_currently_locked" | state.failed_attempts | "critical" | lockout_check_timestamp | 1.0 | account-lockout |
    | state.username | state.password_attempt | state.failed_attempts | disabled | state.login_source | run_in_terminal | {"account_disabled": true, "reason": "policy_violation", "reactivation_required": true, "support_ticket": "required"} | "account_disabled" | state.failed_attempts | "critical" | disabled_timestamp | 1.0 | account-suspended |

@flow:decision_node
@scenario_id:mfa-challenge
@context:multi_factor_authentication,security_verification
Scenario Outline: Process Multi-Factor Authentication
  Given MFA challenge type is <input:state.challenge_type>
  And user response is <input:state.mfa_response>
  And challenge expiry time is <input:state.challenge_expiry>
  And device trust level is <input:state.device_trust>
  When the MFA system validates the response
  Then it should execute tool <mcp_tool:name>
  And set MFA result to <output:state.mfa_result>
  And update device trust to <output:state.device_trust_updated>
  And set session status to <output:state.session_status>
  And transition to <transition>

  Examples: MFA validation decision table
    | input:state.challenge_type | input:state.mfa_response | input:state.challenge_expiry | input:state.device_trust | mcp_tool:name | mcp_tool:output_sample | output:state.mfa_result | output:state.device_trust_updated | output:state.session_status | probability | transition |
    | sms | "correct_code" | state.challenge_expiry > Date.now() | untrusted | semantic_search | {"mfa_success": true, "device_registered": true, "trust_level": "trusted", "session_created": true} | "mfa_successful" | "trusted" | "active_session" | 1.0 | successful-login |
    | app_authenticator | "correct_totp" | state.challenge_expiry > Date.now() | trusted | file_search | {"mfa_success": true, "method": "authenticator", "session_created": true, "enhanced_security": true} | "mfa_successful" | "highly_trusted" | "enhanced_session" | 1.0 | successful-login |
    | sms | "incorrect_code" | state.challenge_expiry > Date.now() | state.device_trust | grep_search | {"mfa_failed": true, "reason": "invalid_code", "attempts_remaining": 2, "challenge_reset": false} | "mfa_failed" | state.device_trust | "pending_verification" | 0.8 | mfa-retry |
    | state.challenge_type | state.mfa_response | state.challenge_expiry <= Date.now() | state.device_trust | run_in_terminal | {"mfa_expired": true, "reason": "challenge_timeout", "new_challenge_required": true, "security_flag": true} | "mfa_expired" | state.device_trust | "session_expired" | 1.0 | login-attempt |
    | sms | "brute_force_attempt" | state.challenge_expiry > Date.now() | untrusted | grep_search | {"mfa_attack_detected": true, "ip_blocked": true, "security_alert": "high", "investigation_required": true} | "mfa_attack_detected" | "blocked" | "security_violation" | 0.9 | verification-blocked |
    | backup_codes | "valid_backup_code" | state.challenge_expiry > Date.now() | state.device_trust | semantic_search | {"backup_code_used": true, "remaining_codes": 7, "regeneration_suggested": true, "session_created": true} | "backup_code_successful" | state.device_trust | "active_session" | 1.0 | successful-login |

@flow:decision_node
@scenario_id:password-reset-request
@context:password_recovery,security_verification
Scenario Outline: Process Password Reset Request
  Given password reset request for user <input:state.reset_username>
  And request verification method is <input:state.verification_method>
  And user email is <input:state.user_email>
  And account status is <input:state.account_status>
  And recent reset attempts are <input:state.recent_resets>
  When the password reset system processes the request
  Then it should execute tool <mcp_tool:name>
  And set reset status to <output:state.reset_status>
  And generate reset token as <output:state.reset_token>
  And set token expiry to <output:state.token_expiry>
  And update reset counter to <output:state.reset_counter>
  And transition to <transition>

  Examples: Password reset request decision table
    | input:state.reset_username | input:state.verification_method | input:state.user_email | input:state.account_status | input:state.recent_resets | mcp_tool:name | mcp_tool:output_sample | output:state.reset_status | output:state.reset_token | output:state.token_expiry | output:state.reset_counter | probability | transition |
    | state.reset_username | email | state.user_email | active | state.recent_resets < 3 | create_file | {"reset_initiated": true, "token": "rst_abc123", "expiry": "1hour", "email_sent": true} | "reset_email_sent" | "rst_" + generate_token() | Date.now() + 3600000 | state.recent_resets + 1 | 1.0 | email-verification |
    | state.reset_username | security_questions | state.user_email | active | state.recent_resets < 5 | semantic_search | {"questions_retrieved": true, "question_count": 3, "challenge_id": "chg_456", "verification_required": true} | "security_questions_presented" | "sqt_" + generate_challenge_id() | Date.now() + 1800000 | state.recent_resets + 1 | 0.8 | security-questions |
    | state.reset_username | state.verification_method | state.user_email | suspended | state.recent_resets | file_search | {"reset_blocked": true, "reason": "account_suspended", "contact_support": true, "escalation_required": true} | "reset_blocked_suspended" | null | null | state.recent_resets | 1.0 | reset-blocked |
    | state.reset_username | state.verification_method | state.user_email | active | state.recent_resets >= 5 | run_in_terminal | {"reset_rate_limited": true, "cooldown_period": "24hours", "security_alert": true, "manual_review": true} | "reset_rate_limited" | null | null | state.recent_resets | 1.0 | reset-rate-limited |
    | state.reset_username | email | "unverified_email" | active | state.recent_resets < 3 | file_search | {"email_unverified": true, "verification_required": true, "identity_confirmation": "required", "enhanced_security": true} | "email_verification_required" | "evr_" + generate_token() | Date.now() + 1800000 | state.recent_resets + 1 | 0.9 | email-verification |
    | "nonexistent_user" | state.verification_method | state.user_email | "not_found" | state.recent_resets | semantic_search | {"user_not_found": true, "security_response": "generic", "no_information_disclosure": true, "attempt_logged": true} | "generic_reset_response" | null | null | state.recent_resets | 1.0 | password-reset-request |

@flow:decision_node
@scenario_id:failed-attempt
@context:failed_login_handling,security_monitoring
Scenario Outline: Handle Failed Login Attempts
  Given failed login attempt for user <input:state.username>
  And current failed attempt count is <input:state.failed_attempts>
  And time since last attempt is <input:state.time_since_last>
  And login source IP is <input:state.source_ip>
  And account lockout threshold is <input:state.lockout_threshold>
  When the failed attempt handler processes the failure
  Then it should execute tool <mcp_tool:name>
  And set attempt status to <output:state.attempt_status>
  And update security flags to <output:state.security_flags>
  And set next action to <output:state.next_action>
  And record attempt timestamp as <output:state.attempt_timestamp>
  And transition to <transition>

  Examples: Failed attempt handling decision table
    | input:state.username | input:state.failed_attempts | input:state.time_since_last | input:state.source_ip | input:state.lockout_threshold | mcp_tool:name | mcp_tool:output_sample | output:state.attempt_status | output:state.security_flags | output:state.next_action | output:state.attempt_timestamp | probability | transition |
    | state.username | state.failed_attempts + 1 | state.time_since_last < 300 | "suspicious_ip" | state.lockout_threshold | semantic_search | {"suspicious_activity": true, "ip_flagged": true, "enhanced_monitoring": true, "rate_limit": true} | "suspicious_activity_detected" | "enhanced_monitoring,ip_flagged" | "immediate_lockout" | new Date().toISOString() | 0.9 | account-lockout |
    | state.username | state.failed_attempts + 1 | state.time_since_last >= 300 | "trusted_ip" | state.lockout_threshold | file_search | {"attempt_recorded": true, "warning_issued": true, "grace_period": true, "attempts_remaining": 1} | "attempt_recorded_warning" | "warning_issued" | "allow_retry_with_warning" | current_timestamp | 1.0 | login-attempt |
    | state.username | state.failed_attempts + 1 | state.time_since_last | state.source_ip | state.failed_attempts >= state.lockout_threshold | run_in_terminal | {"lockout_triggered": true, "threshold_exceeded": true, "security_alert": true, "admin_notification": true} | "lockout_threshold_exceeded" | "account_locked,admin_notified" | "initiate_lockout_procedure" | lockout_timestamp | 1.0 | account-lockout |

@flow:decision_node
@scenario_id:email-verification
@context:email_verification,token_validation
Scenario Outline: Process Email Verification for Password Reset
  Given password reset email token <input:state.email_token>
  And token expiry time is <input:state.token_expiry>
  And user email verification status is <input:state.email_verified>
  And click timestamp is <input:state.click_timestamp>
  When the email verification system validates the token
  Then it should execute tool <mcp_tool:name>
  And set token validation result to <output:state.token_validation>
  And update verification status to <output:state.verification_status>
  And set access level to <output:state.access_level>
  And transition to <transition>

  Examples: Email verification decision table
    | input:state.email_token | input:state.token_expiry | input:state.email_verified | input:state.click_timestamp | mcp_tool:name | mcp_tool:output_sample | output:state.token_validation | output:state.verification_status | output:state.access_level | probability | transition |
    | "valid_token" | state.token_expiry > Date.now() | true | state.click_timestamp | semantic_search | {"token_valid": true, "email_verified": true, "reset_authorized": true, "secure_session": true} | "token_validated_successfully" | "email_verification_complete" | "password_reset_authorized" | 1.0 | password-reset-form |
    | "invalid_token" | state.token_expiry | state.email_verified | state.click_timestamp | file_search | {"token_invalid": true, "reason": "token_not_found", "new_token_required": true, "security_logged": true} | "token_validation_failed" | "invalid_token_provided" | "access_denied" | 0.9 | password-reset-request |
    | state.email_token | state.token_expiry <= Date.now() | state.email_verified | state.click_timestamp | grep_search | {"token_expired": true, "reason": "time_exceeded", "new_request_required": true, "cleanup_initiated": true} | "token_expired" | "verification_timeout" | "access_denied" | 1.0 | password-reset-request |
    | state.email_token | state.token_expiry | false | state.click_timestamp | run_in_terminal | {"email_unverified": true, "verification_required": true, "additional_steps": true, "security_enhanced": true} | "email_verification_required" | "email_not_verified" | "limited_access" | 0.8 | email-verification |

@flow:decision_node
@scenario_id:mfa-retry
@context:mfa_retry_handling,security_verification
Scenario Outline: Handle MFA Retry Attempts
  Given MFA retry attempt for challenge <input:state.challenge_id>
  And current retry count is <input:state.mfa_retry_count>
  And maximum retries allowed is <input:state.max_mfa_retries>
  And challenge type is <input:state.challenge_type>
  When the MFA retry system processes the attempt
  Then it should execute tool <mcp_tool:name>
  And set retry status to <output:state.retry_status>
  And update retry counter to <output:state.retry_counter>
  And set security action to <output:state.security_action>
  And transition to <transition>

  Examples: MFA retry decision table
    | input:state.challenge_id | input:state.mfa_retry_count | input:state.max_mfa_retries | input:state.challenge_type | mcp_tool:name | mcp_tool:output_sample | output:state.retry_status | output:state.retry_counter | output:state.security_action | probability | transition |
    | state.challenge_id | state.mfa_retry_count + 1 | state.mfa_retry_count < state.max_mfa_retries | state.challenge_type | semantic_search | {"retry_allowed": true, "new_challenge": true, "attempt_logged": true, "warning_issued": true} | "retry_attempt_allowed" | state.mfa_retry_count + 1 | "issue_warning" | 1.0 | mfa-challenge |
    | state.challenge_id | state.mfa_retry_count + 1 | state.mfa_retry_count >= state.max_mfa_retries | state.challenge_type | run_in_terminal | {"retry_exceeded": true, "session_terminated": true, "security_alert": true, "cooldown_initiated": true} | "max_retries_exceeded" | state.mfa_retry_count + 1 | "terminate_session" | 1.0 | login-attempt |

@flow:chance_node
@scenario_id:security-questions
@context:identity_verification,knowledge_based_auth
Scenario Outline: Process Security Questions Verification
  Given security questions presented to user <input:state.reset_username>
  And user answers are <input:state.question_answers>
  And correct answer count is <input:state.correct_answers>
  And verification attempt number is <input:state.verification_attempts>
  When the security question system validates responses
  Then it should execute tool <mcp_tool:name>
  And set verification result to <output:state.verification_result>
  And update verification status to <output:state.verification_status>
  And set access level to <output:state.access_level>
  And transition to <transition>

  Examples: Security questions verification decision table (chance node with probabilities)
    | input:state.reset_username | input:state.question_answers | input:state.correct_answers | input:state.verification_attempts | mcp_tool:name | mcp_tool:output_sample | output:state.verification_result | output:state.verification_status | output:state.access_level | probability | transition |
    | state.reset_username | "all_correct" | 3 | state.verification_attempts < 2 | semantic_search | {"verification_passed": true, "confidence": "high", "reset_authorized": true, "bypass_email": false} | "verification_successful" | "identity_confirmed" | "password_reset_allowed" | 0.8 | password-reset-form |
    | state.reset_username | "partial_correct" | 2 | state.verification_attempts < 3 | file_search | {"verification_partial": true, "additional_verification": true, "email_required": true, "security_enhanced": true} | "partial_verification" | "additional_auth_required" | "email_verification_required" | 0.6 | email-verification |
    | state.reset_username | "mostly_incorrect" | state.correct_answers < 2 | state.verification_attempts < 3 | grep_search | {"verification_failed": true, "retry_allowed": true, "security_flag": false, "attempt_recorded": true} | "verification_failed_retry" | "retry_allowed" | "limited_access" | 0.3 | security-questions |
    | state.reset_username | state.question_answers | state.correct_answers < 2 | state.verification_attempts >= 3 | run_in_terminal | {"verification_blocked": true, "max_attempts_exceeded": true, "security_alert": true, "manual_review": true} | "verification_blocked" | "too_many_attempts" | "access_denied" | 0.9 | verification-blocked |

@flow:decision_node
@scenario_id:password-reset-form
@context:password_creation,policy_validation
Scenario Outline: Process New Password Submission
  Given new password is <input:state.new_password>
  And password confirmation is <input:state.password_confirmation>
  And password strength score is <input:state.password_strength>
  And password history check is <input:state.password_history>
  And reset token is <input:state.reset_token>
  When the password update system validates the new password
  Then it should execute tool <mcp_tool:name>
  And set password update status to <output:state.password_status>
  And update password history to <output:state.password_history_updated>
  And set account security level to <output:state.account_security>
  And record password change timestamp as <output:state.password_change_time>
  And transition to <transition>

  Examples: Password reset completion decision table
    | input:state.new_password | input:state.password_confirmation | input:state.password_strength | input:state.password_history | input:state.reset_token | mcp_tool:name | mcp_tool:output_sample | output:state.password_status | output:state.password_history_updated | output:state.account_security | output:state.password_change_time | probability | transition |
    | "strong_password" | state.new_password == state.password_confirmation | state.password_strength >= 8 | not_in_recent_history | "valid_token" | create_file | {"password_updated": true, "hash_created": true, "security_enhanced": true, "notification_sent": true} | "password_successfully_updated" | state.password_history.append(new_hash) | "enhanced" | new Date().toISOString() | 1.0 | password-reset-complete |
    | state.new_password | state.new_password != state.password_confirmation | state.password_strength | state.password_history | state.reset_token | file_search | {"password_mismatch": true, "error": "passwords_do_not_match", "retry_required": true, "validation_failed": true} | "password_mismatch_error" | state.password_history | "unchanged" | null | 0.9 | password-reset-form |
    | "weak_password" | state.password_confirmation | state.password_strength < 6 | state.password_history | state.reset_token | semantic_search | {"password_weak": true, "requirements": ["8_chars", "uppercase", "numbers", "symbols"], "retry_required": true} | "password_policy_violation" | state.password_history | "unchanged" | null | 1.0 | password-reset-form |
    | state.new_password | state.password_confirmation | state.password_strength | in_recent_history | state.reset_token | grep_search | {"password_reused": true, "error": "password_recently_used", "history_check_failed": true, "new_password_required": true} | "password_reuse_violation" | state.password_history | "unchanged" | null | 0.8 | password-reset-form |
    | state.new_password | state.password_confirmation | state.password_strength | state.password_history | "expired_token" | run_in_terminal | {"token_expired": true, "reset_session_invalid": true, "new_request_required": true, "security_cleanup": true} | "reset_token_expired" | state.password_history | "unchanged" | null | 1.0 | password-reset-request |
    | "password_with_dictionary_words" | state.password_confirmation | state.password_strength >= 6 | state.password_history | state.reset_token | semantic_search | {"dictionary_check_failed": true, "common_password": true, "enhanced_requirements": true, "strength_insufficient": true} | "password_too_common" | state.password_history | "unchanged" | null | 0.9 | password-reset-form |

@flow:end_node
@scenario_id:successful-login
@context:session_creation,access_granted
Scenario Outline: Complete Successful Authentication
  Given authentication result is <input:state.auth_result>
  And user session data is <input:state.session_data>
  And access permissions are <input:state.access_permissions>
  And login security level is <input:state.security_level>
  When the session management system creates user session
  Then it should execute tool <mcp_tool:name>
  And set final session status to <output:state.final_session_status>
  And record session ID as <output:state.session_id>
  And update last login timestamp to <output:state.last_login>
  And set access token to <output:state.access_token>

  Examples: Successful login completion table
    | input:state.auth_result | input:state.session_data | input:state.access_permissions | input:state.security_level | mcp_tool:name | mcp_tool:output_sample | output:state.final_session_status | output:state.session_id | output:state.last_login | output:state.access_token | probability | transition |
    | "authentication_successful" | state.session_data | "full_access" | "standard" | create_file | {"session_created": true, "session_id": "sess_123abc", "access_token": "tok_xyz789", "expires_in": 3600} | "active_session_created" | "sess_" + generate_session_id() | new Date().toISOString() | "tok_" + generate_access_token() | 1.0 | |
    | "mfa_successful" | state.session_data | "enhanced_access" | "enhanced" | semantic_search | {"secure_session": true, "session_id": "sess_456def", "enhanced_token": "etok_abc123", "elevated_permissions": true} | "enhanced_session_created" | "sess_" + generate_secure_id() | secure_timestamp | "etok_" + generate_enhanced_token() | 1.0 | |

@flow:end_node
@scenario_id:account-lockout
@context:security_lockout,access_denied
Scenario Outline: Process Account Lockout
  Given lockout reason is <input:state.lockout_reason>
  And lockout duration is <input:state.lockout_duration>
  And failed attempt count is <input:state.failed_attempts>
  And lockout timestamp is <input:state.lockout_timestamp>
  When the account lockout system processes the security event
  Then it should execute tool <mcp_tool:name>
  And set lockout status to <output:state.lockout_status>
  And record unlock time as <output:state.unlock_time>
  And set notification status to <output:state.notification_status>
  And create security alert as <output:state.security_alert>

  Examples: Account lockout completion table
    | input:state.lockout_reason | input:state.lockout_duration | input:state.failed_attempts | input:state.lockout_timestamp | mcp_tool:name | mcp_tool:output_sample | output:state.lockout_status | output:state.unlock_time | output:state.notification_status | output:state.security_alert | probability | transition |
    | "excessive_failed_attempts" | state.lockout_duration | state.failed_attempts | state.lockout_timestamp | run_in_terminal | {"account_locked": true, "unlock_time": "2025-11-01T11:30:00Z", "email_sent": true, "security_logged": true} | "temporarily_locked" | calculate_unlock_time(state.lockout_duration) | "user_notified" | "high_priority_alert_created" | 1.0 | |

@flow:end_node
@scenario_id:password-reset-complete
@context:password_updated,security_enhanced
Scenario Outline: Complete Password Reset Process
  Given password update status is <input:state.password_status>
  And new password security level is <input:state.password_security>
  And reset completion timestamp is <input:state.reset_completion_time>
  When the password reset system finalizes the process
  Then it should execute tool <mcp_tool:name>
  And set final reset status to <output:state.final_reset_status>
  And update account security profile to <output:state.security_profile>
  And record completion in audit log as <output:state.audit_entry>
  And set user notification status to <output:state.user_notification>

  Examples: Password reset completion table
    | input:state.password_status | input:state.password_security | input:state.reset_completion_time | mcp_tool:name | mcp_tool:output_sample | output:state.final_reset_status | output:state.security_profile | output:state.audit_entry | output:state.user_notification | probability | transition |
    | "password_successfully_updated" | "enhanced" | state.reset_completion_time | create_file | {"reset_completed": true, "security_enhanced": true, "audit_logged": true, "user_notified": true} | "password_reset_successful" | "security_enhanced_profile" | "password_reset_completed_" + state.timestamp | "success_notification_sent" | 1.0 | |

@flow:end_node
@scenario_id:verification-blocked
@context:security_violation,access_denied
Scenario Outline: Handle Verification Blocking
  Given verification blocking reason is <input:state.blocking_reason>
  And security violation level is <input:state.violation_level>
  And blocking timestamp is <input:state.blocking_timestamp>
  When the security system processes the violation
  Then it should execute tool <mcp_tool:name>
  And set blocking status to <output:state.blocking_status>
  And create security incident as <output:state.security_incident>
  And set manual review flag to <output:state.manual_review_required>
  And record violation in security log as <output:state.security_log_entry>

  Examples: Verification blocking completion table
    | input:state.blocking_reason | input:state.violation_level | input:state.blocking_timestamp | mcp_tool:name | mcp_tool:output_sample | output:state.blocking_status | output:state.security_incident | output:state.manual_review_required | output:state.security_log_entry | probability | transition |
    | "too_many_verification_attempts" | "high" | state.blocking_timestamp | run_in_terminal | {"verification_blocked": true, "incident_created": "INC-SEC-001", "manual_review": true, "security_team_notified": true} | "verification_permanently_blocked" | "INC-SEC-" + generate_incident_id() | "immediate_review_required" | "security_violation_" + state.timestamp | 1.0 | |

@flow:end_node
@scenario_id:reset-rate-limited
@context:rate_limiting,security_protection
Scenario Outline: Handle Password Reset Rate Limiting
  Given rate limit violation for user <input:state.reset_username>
  And recent reset attempts count is <input:state.recent_resets>
  And cooldown period is <input:state.cooldown_period>
  And rate limit violation timestamp is <input:state.violation_timestamp>
  When the rate limiting system processes the violation
  Then it should execute tool <mcp_tool:name>
  And set rate limit status to <output:state.rate_limit_status>
  And record cooldown expiry as <output:state.cooldown_expiry>
  And create security alert as <output:state.security_alert>
  And set user notification to <output:state.user_notification>

  Examples: Rate limiting completion table
    | input:state.reset_username | input:state.recent_resets | input:state.cooldown_period | input:state.violation_timestamp | mcp_tool:name | mcp_tool:output_sample | output:state.rate_limit_status | output:state.cooldown_expiry | output:state.security_alert | output:state.user_notification | probability | transition |
    | state.reset_username | state.recent_resets | state.cooldown_period | state.violation_timestamp | run_in_terminal | {"rate_limited": true, "cooldown_active": true, "alert_created": "RATE-001", "user_notified": true} | "password_reset_rate_limited" | calculate_cooldown_expiry(state.cooldown_period) | "rate_limit_violation_alert" | "cooldown_notification_sent" | 1.0 | |

@flow:end_node
@scenario_id:reset-blocked
@context:reset_blocking,security_violation
Scenario Outline: Handle Blocked Password Reset
  Given password reset blocking reason <input:state.blocking_reason>
  And account status is <input:state.account_status>
  And blocking timestamp is <input:state.blocking_timestamp>
  When the blocking system processes the restriction
  Then it should execute tool <mcp_tool:name>
  And set blocking status to <output:state.blocking_status>
  And create support ticket as <output:state.support_ticket>
  And set escalation level to <output:state.escalation_level>
  And record blocking reason as <output:state.recorded_reason>

  Examples: Reset blocking completion table
    | input:state.blocking_reason | input:state.account_status | input:state.blocking_timestamp | mcp_tool:name | mcp_tool:output_sample | output:state.blocking_status | output:state.support_ticket | output:state.escalation_level | output:state.recorded_reason | probability | transition |
    | "account_suspended" | "suspended" | state.blocking_timestamp | create_file | {"reset_blocked": true, "ticket_created": "SUP-001", "escalation": "immediate", "manual_review": true} | "password_reset_blocked" | "SUP-" + generate_ticket_id() | "immediate_escalation" | state.blocking_reason + "_documented" | 1.0 | |

@flow:end_node
@scenario_id:account-suspended
@context:account_suspension,access_denied
Scenario Outline: Handle Suspended Account Access
  Given account suspension reason <input:state.suspension_reason>
  And suspension timestamp is <input:state.suspension_timestamp>
  And contact support information <input:state.support_contact>
  When the suspension system processes the access attempt
  Then it should execute tool <mcp_tool:name>
  And set suspension status to <output:state.suspension_status>
  And create incident record as <output:state.incident_record>
  And set support escalation to <output:state.support_escalation>
  And record access denial as <output:state.access_denial_record>

  Examples: Account suspension completion table
    | input:state.suspension_reason | input:state.suspension_timestamp | input:state.support_contact | mcp_tool:name | mcp_tool:output_sample | output:state.suspension_status | output:state.incident_record | output:state.support_escalation | output:state.access_denial_record | probability | transition |
    | state.suspension_reason | state.suspension_timestamp | state.support_contact | create_file | {"access_denied": true, "incident": "INC-SUS-001", "support_contact": "support@company.com", "escalation": "tier2"} | "account_access_suspended" | "INC-SUS-" + generate_incident_id() | "tier2_support_escalation" | "access_denied_" + state.timestamp | 1.0 | |