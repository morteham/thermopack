!> Tuning of HV data
subroutine thermopack_getHVparam(i,j,alpha_ij,alpha_ji,aGE_ij,aGE_ji,bGE_ij,bGE_ji,cGE_ij,cGE_ji)
  use thermopack_var
  use cubic_eos, only: cb_eos
  implicit none
  integer, intent(in) :: i,j
  real, intent(out) :: alpha_ij,alpha_ji,aGE_ij,aGE_ji,bGE_ij,bGE_ji,cGE_ij,cGE_ji
  class(base_eos_param), pointer :: act_eos_ptr
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    if (.not. allocated(p_eos%mixGE%alpha)) then
      call stoperror('p_eos%mixGEalpha not allocated')
    endif
    if (.not. allocated(p_eos%mixGE%aGE)) then
      call stoperror('p_eos%mixGE%aGE not allocated')
    endif
    if (.not. allocated(p_eos%mixGE%bGE)) then
      call stoperror('p_eos%mixGE%bGE not allocated')
    endif
    if (.not. allocated(p_eos%mixGE%cGE)) then
      call stoperror('p_eos%mixGE%cGE not allocated')
    endif
    alpha_ij = p_eos%mixGE%alpha(i,j)
    alpha_ji = p_eos%mixGE%alpha(j,i)
    aGE_ij = p_eos%mixGE%aGE(i,j)
    aGE_ji = p_eos%mixGE%aGE(j,i)
    bGE_ij = p_eos%mixGE%bGE(i,j)
    bGE_ji = p_eos%mixGE%bGE(j,i)
    cGE_ij = p_eos%mixGE%cGE(i,j)
    cGE_ji = p_eos%mixGE%cGE(j,i)
  class default
    print *,"thermopack_getHVparam: Wrong model - no HV parameters"
  end select
end subroutine thermopack_getHVparam

!> Tuning of HV data
subroutine thermopack_setHVparam(i,j,alpha_ij,alpha_ji,aGE_ij,aGE_ji,bGE_ij,bGE_ji,cGE_ij,cGE_ji)
  use thermopack_var
  use cubic_eos, only: cb_eos
  implicit none
  integer, intent(in) :: i,j
  real, intent(in) :: alpha_ij,alpha_ji,aGE_ij,aGE_ji,bGE_ij,bGE_ji,cGE_ij,cGE_ji
  !
  class(base_eos_param), pointer :: act_eos_ptr
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    if (.not. allocated(p_eos%mixGE%alpha)) then
      call stoperror('p_eos%mixGE%alpha not allocated')
    endif
    if (.not. allocated(p_eos%mixGE%aGE)) then
      call stoperror('p_eos%mixGE%aGE not allocated')
    endif
    if (.not. allocated(p_eos%mixGE%bGE)) then
      call stoperror('p_eos%mixGE%bGE not allocated')
    endif
    if (.not. allocated(p_eos%mixGE%cGE)) then
      call stoperror('p_eos%mixGE%cGE not allocated')
    endif
    p_eos%mixGE%alpha(i,j) = alpha_ij
    p_eos%mixGE%alpha(j,i) = alpha_ji
    p_eos%mixGE%aGE(i,j) = aGE_ij
    p_eos%mixGE%aGE(j,i) = aGE_ji
    p_eos%mixGE%bGE(i,j) = bGE_ij
    p_eos%mixGE%bGE(j,i) = bGE_ji
    p_eos%mixGE%cGE(i,j) = cGE_ij
    p_eos%mixGE%cGE(j,i) = cGE_ji
    p_eos%mixGE%correlation(i,j) = 1
    p_eos%mixGE%correlation(j,i) = 1
  class default
    print *,"thermopack_setHVparam: Wrong model - no HV parameters"
  end select
end subroutine thermopack_setHVparam

!> Tuning of TWU alpha correlation
subroutine thermopack_getTWUparam(i,c_1,c_2,c_3)
  use thermopack_var
  use cubic_eos, only: cb_eos
  implicit none
  integer, intent(in) :: i
  real, intent(out) :: c_1,c_2,c_3
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    c_1 = p_eos%single(i)%alphaParams(1)
    c_2 = p_eos%single(i)%alphaParams(2)
    c_3 = p_eos%single(i)%alphaParams(3)
  class default
    print *,"thermopack_getTWUparam: Wrong model - no TWU parameters"
  end select
end subroutine thermopack_getTWUparam

!> Tuning of TWU alpha correlation. If eoslibinit wasn't initilized with
!> TWU, TWU becomes the new alpha correlation.
subroutine thermopack_setTWUparam(i,c_1,c_2,c_3)
  use cbAlpha, only: setSingleAlphaCorr
  use thermopack_var
  use cubic_eos, only: cb_eos, cbAlphaTwuIdx
  implicit none
  integer, intent(in) :: i
  real, intent(in) :: c_1,c_2,c_3
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    call setSingleAlphaCorr(i, p_eos, alphaIdx=cbAlphaTwuIdx, alphaParams=(/c_1,c_2,c_3/))
  class default
    print *,"thermopack_setTWUparam: Wrong model - no TWU parameters"
  end select
end subroutine thermopack_setTWUparam

!> Retrieve TWU parameters
subroutine thermopack_getMCparam(i,c_1,c_2,c_3)
  use thermopack_var
  use cubic_eos, only: cb_eos
  implicit none
  integer, intent(in) :: i
  real, intent(out) :: c_1,c_2,c_3
  !
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    c_1 = p_eos%single(i)%alphaParams(1)
    c_2 = p_eos%single(i)%alphaParams(2)
    c_3 = p_eos%single(i)%alphaParams(3)
  class default
    print *,"thermopack_getMCparam: Wrong model - no MC parameters"
  end select
end subroutine thermopack_getMCparam

!> Tuning of MC alpha correlation. If eoslibinit wasn't initilized with
!> MC, MC becomes the new alpha correlation.
subroutine thermopack_setMCparam(i,c_1,c_2,c_3)
  use cbAlpha, only: setSingleAlphaCorr
  use thermopack_var
  use cubic_eos, only: cb_eos, cbAlphaMCIdx
  implicit none
  integer, intent(in) :: i
  real, intent(in) :: c_1,c_2,c_3
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    call setSingleAlphaCorr(i, p_eos, alphaIdx=cbAlphaMCIdx, alphaParams=(/c_1,c_2,c_3/))
  class default
    print *,"thermopack_setMCparam: Wrong model - no MC parameters"
  end select
end subroutine thermopack_setMCparam

subroutine thermopack_setClassicFitparam(i,c_1)
  use cbAlpha, only: setSingleAlphaCorr
  use thermopack_var
  use cubic_eos, only: cb_eos
  implicit none
  integer, intent(in) :: i
  real, intent(in) :: c_1
  ! Locals
  integer :: alphaIdx
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    alphaIdx = p_eos%single(i)%alphaMethod
    call setSingleAlphaCorr(i, p_eos, alphaIdx=alphaIdx, alphaParams=(/c_1/))
  class default
    print *,"thermopack_setClassicFitparam: Wrong model - no ClassicFit parameters"
  end select
end subroutine thermopack_setClassicFitparam

!> Tuning of vdW kij interaction parameters
subroutine thermopack_getkij(i,j,kij)
  use thermopack_var
  use cubic_eos, only: cb_eos
  implicit none
  integer, intent(in) :: i,j
  real, intent(out) :: kij
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    kij = p_eos%kij(i,j)
  class default
    print *,"thermopack_getkij: Wrong model - not cubic"
  end select
end subroutine thermopack_getkij

!> Tuning of vdW kij interaction parameters
subroutine thermopack_setkij(i,j,kij)
  use thermopack_var
  use cubic_eos, only: cb_eos
  implicit none
  integer, intent(in) :: i,j
  real, intent(in) :: kij
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_eos_ptr => get_active_eos()
  !
  select type(p_eos => act_eos_ptr)
  class is (cb_eos)
    p_eos%kij(i,j) = kij
  class default
    print *,"thermopack_setkij: Wrong model - not cubic"
  end select
end subroutine thermopack_setkij

!> Tuning of kij interaction parameters
subroutine thermopack_setkijandji(i,j,kij)
  use thermopack_var
  use eos_parameters, only: single_eos
  use cubic_eos, only: cb_eos, cpa_eos
  use saftvrmie_containers, only: set_saftvrmie_eps_kij, saftvrmie_eos
  use saft_interface, only: pc_saft_set_kij
  use pc_saft_nonassoc, only: PCSAFT_eos
  implicit none
  integer, intent(in) :: i,j
  real, intent(in) :: kij
  type(thermo_model), pointer :: act_mod_ptr
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_mod_ptr => get_active_thermo_model()
  act_eos_ptr => get_active_eos()
  select type (p_eos => act_eos_ptr)
  class is (cb_eos)
    p_eos%kij(i,j) = kij
    p_eos%kij(j,i) = kij
  type is(cpa_eos)
    call stoperror("Not able to set binary kij for CPA eos.")
  type is(PCSAFT_eos)
    call pc_saft_set_kij(i,j,kij)
  type is(single_eos)
    call stoperror("Not able to set binary kij for single comp. eos.")
  type is(saftvrmie_eos)
    call set_saftvrmie_eps_kij(i,j,kij)
  class default
    call stoperror("Not able to set binary kij for selected model")
  end select

end subroutine thermopack_setkijandji

!> Tuning of lij interaction parameters
subroutine thermopack_setlijandji(i,j,lij)
  use thermopack_var
  use eos_parameters, only: single_eos
  use cubic_eos, only: cb_eos, cpa_eos
  use saftvrmie_containers, only: set_saftvrmie_sigma_lij, saftvrmie_eos
  use saft_interface, only: pc_saft_set_kij
  use pc_saft_nonassoc, only: PCSAFT_eos
  implicit none
  integer, intent(in) :: i,j
  real, intent(in) :: lij
  type(thermo_model), pointer :: act_mod_ptr
  class(base_eos_param), pointer :: act_eos_ptr
  !
  act_mod_ptr => get_active_thermo_model()
  act_eos_ptr => get_active_eos()
  select type (p_eos => act_eos_ptr)
  class is (cb_eos)
    call stoperror("Not able to set binary lij for Cubic eos.")
  type is(cpa_eos)
    call stoperror("Not able to set binary lij for CPA eos.")
  type is(PCSAFT_eos)
    call stoperror("Not able to set binary lij for PC-SAFT eos.")
  type is(single_eos)
    call stoperror("Not able to set binary lij for single comp. eos.")
  type is(saftvrmie_eos)
    call set_saftvrmie_sigma_lij(i,j,lij)
  class default
    call stoperror("Not able to set binary lij for selected model")
  end select
end subroutine thermopack_setlijandji

!> Get volume translation parameter
subroutine thermopack_get_volume_shift_parameter(i,ci)
  use thermopack_var
  implicit none
  integer, intent(in) :: i
  real, intent(out) :: ci
  ! Locals
  type(thermo_model), pointer :: act_mod_ptr
  !
  act_mod_ptr => get_active_thermo_model()
  ci = act_mod_ptr%comps(i)%p_comp%ci
end subroutine thermopack_get_volume_shift_parameter

!> Tuning of volume translation parameter
subroutine thermopack_set_volume_shift_parameter(i,ci)
  use thermopack_var
  implicit none
  integer, intent(in) :: i
  real, intent(in) :: ci
  ! Locals
  type(thermo_model), pointer :: act_mod_ptr
  !
  act_mod_ptr => get_active_thermo_model()
  act_mod_ptr%comps(i)%p_comp%ci = ci
end subroutine thermopack_set_volume_shift_parameter
