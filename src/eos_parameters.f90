!> The module eosdata contains the definitions of the equation of state, mixing
!> rule and the interaction parameters.

Module eos_parameters
  use compdata
  use eosdata
  use thermopack_var, only: complist, base_eos_param, base_eos_dealloc
  Use multiparameter_base, only: meos, nist_meos_ptr
  use multiparameter_c3, only: meos_c3
  use multiparameter_ortho_h2, only: meos_ortho_h2
  use multiparameter_para_h2, only: meos_para_h2
  use multiparameter_normal_h2, only: meos_normal_h2
  use multiparameter_r134a, only: meos_r134a
  use mbwr, only: eosmbwr, initializeMBWRmodel
  implicit none

  ! type, abstract :: base_eos_param
  !   ! Base class for holding eos-data
  !   character (len=eosid_len) :: eosid !< Eos identefyer
  !   !character (len=eos_name_len) :: label !< Name of EOS
  !   integer :: eosidx !< Eos group index
  !   integer :: subeosidx !< Eos sub-index
  !   integer :: volumeShiftId = 0 !< 0: No volume shift, 1:Peneloux shift
  !   logical :: isElectrolyteEoS = .false. !< Used to enable electrolytes

  ! contains
  !   procedure(allocate_and_init_intf), deferred, public :: allocate_and_init
  !   ! Assignment operator
  !   !generic,   public, deferred   :: assignment(=)

  ! end type base_eos_param

  ! abstract interface
  !   subroutine allocate_and_init_intf(eos,nc,eos_label)
  !     import base_eos_param
  !     ! Passed object:
  !     class(base_eos_param), intent(inout) :: eos
  !     ! Input:
  !     integer, intent(in) :: nc !< Number of components
  !     character(len=*), intent(in) :: eos_label !< EOS label
  !   end subroutine allocate_and_init_intf
  ! end interface

  ! type :: eos_param_pointer
  !   class(base_eos_param), pointer :: p_eos
  ! end type eos_param_pointer

  type, extends(base_eos_param) :: single_eos
    ! Multiparameter equations of state for pure components
    type(eosmbwr), allocatable :: mbwr_meos(:)
    type(nist_meos_ptr), allocatable :: nist(:)
  contains
    procedure, public :: dealloc => single_eos_dealloc
    procedure, public :: allocate_and_init => single_eos_allocate_and_init
    ! Assignment operator
    procedure, pass(This), public :: assign_eos => assign_single_eos_set
    !procedure, pass(This), public :: assign_eos_get => assign_single_eos_get
    !generic, public :: assignment(=) => assign_eos_get

  end type single_eos

  type, extends(single_eos) :: meos_mix

  end type meos_mix

  ! type, extends(base_eos_param) :: saftvrmie_eos

  ! !   private

  ! ! contains
  ! end type saftvrmie_eos

contains

  ! ! Functions for allocate statement:
  ! function cpaeos_constructor(....) result(cpa_eos)
  !   ! Input:
  !   ! Created object:
  !   type(cpaeos) :: cpa_eos
  !   ! Locals
  ! end function cpaeos_constructor

  subroutine single_eos_allocate_and_init(eos,nc,eos_label)
    ! Passed object:
    class(single_eos), intent(inout) :: eos
    ! Input:
    integer, intent(in) :: nc !< Number of components
    character(len=*), intent(in) :: eos_label !< EOS label
    ! Locals
    integer :: istat, i
    call eos%dealloc()
    istat = 0
    if (str_eq(eos_label,'MBWR19') .or. str_eq(eos_label,'MBWR32')) then
      if (nc /= 1) call stoperror("MBWR equation only for single component.")
      allocate(eos%mbwr_meos(1), stat=istat)
      if (istat /= 0) call stoperror('Error allocating mbwr_meos')
      if (str_eq(eos_label,'MBWR19')) then
        call initializeMBWRmodel(complist(1), eos%mbwr_meos(1), 19)
      else
        call initializeMBWRmodel(complist(1), eos%mbwr_meos(1), 32)
      endif
    else if (str_eq(eos_label,'NIST_MEOS') .or. str_eq(eos_label,'NIST_MEOS_MIX')) then
      if (str_eq(eos_label,'NIST_MEOS')) then
        if (nc /= 1) call stoperror("NIST_MEOS only implemented for pure components.")
      endif
      allocate(eos%nist(nc), STAT=istat)
      if (istat /= 0) call stoperror('Error allocating nist')
      do i=1,nc
        call single_eos_alloc(complist(i),eos%nist(i)%meos)
        call eos%nist(i)%meos%init()
      enddo
    else
      call stoperror("Wrong input to single_eos_allocate_and_init")
    endif
  end subroutine single_eos_allocate_and_init

  ! \author Morten H
  subroutine single_eos_alloc(comp,meos_ptr)
    ! Passed object:
    class(meos), pointer, intent(inout) :: meos_ptr
    character(len=*), intent(in) :: comp
    ! Locals
    integer :: istat
    istat = 0
    if (str_eq(comp, "C3")) then
      allocate(meos_c3 :: meos_ptr, stat=istat)
    elseif (str_eq(comp,"N-H2")) then
      allocate(meos_normal_h2 :: meos_ptr, stat=istat)
    elseif (str_eq(comp,"O-H2")) then
      allocate(meos_ortho_h2 :: meos_ptr, stat=istat)
    elseif (str_eq(comp,"P-H2")) then
      allocate(meos_para_h2 :: meos_ptr, stat=istat)
    elseif (str_eq(comp,"R134A")) then
      allocate(meos_r134a :: meos_ptr, stat=istat)
    else
      call stoperror("Only possible to use NIST MEOS with components: C3 or N/O/P-H2, or R134A")
    end if
    if (istat /= 0) call stoperror("Not able to allocate meos_ptr")
  end subroutine single_eos_alloc

  !! \author Morten H
  subroutine single_eos_dealloc(eos)
    use utilities, only: deallocate_real
    ! Passed object:
    class(single_eos), intent(inout) :: eos
    ! Locals
    integer :: i, istat
    call base_eos_dealloc(eos)
    istat = 0
    if (allocated(eos%mbwr_meos)) then
      do i=1,size(eos%mbwr_meos)
        call eos%mbwr_meos(i)%dealloc()
      enddo
      deallocate(eos%mbwr_meos, STAT=istat)
      if (istat /= 0) call stoperror('Error deallocating mbwr_meos')
    endif
    if (allocated (eos%nist)) then
      do i=1,size(eos%nist)
        deallocate (eos%nist(i)%meos, STAT=istat)
        if (istat /= 0) call stoperror('Error deallocating nist(i)%meos')
      enddo
      deallocate (eos%nist, STAT=istat)
      if (istat /= 0) call stoperror('Error deallocating nist')
    endif
  end subroutine single_eos_dealloc

  !> Allocate memory for single eos
  function single_eos_constructor(nc, eos_label) result(s_eos)
    ! Input:
    integer, intent(in) :: nc
    character(len=*), intent(in) :: eos_label
    ! Created object:
    type(single_eos) :: s_eos
    !
    call s_eos%allocate_and_init(nc, eos_label)
  end function single_eos_constructor

  !> Allocate memory for single eos
  function meos_mix_constructor(nc, eos_label) result(meos)
    ! Input:
    integer, intent(in) :: nc
    character(len=*), intent(in) :: eos_label
    ! Created object:
    type(meos_mix) :: meos
    !
    call meos%allocate_and_init(nc, eos_label)
  end function meos_mix_constructor

  ! subroutine assign_single_eos_get(other, this)
  !   integer, intent(inout)       :: other
  !   class(myintprop), intent(in) :: this

  !   value = this%myvalue
  ! end subroutine assign_single_eos_get

  subroutine assign_single_eos_set(This, other)
    class(single_eos), intent(inout) :: this
    class(*), intent(in)           :: other
    ! Locals
    integer :: i, istat
    select type (other)
    class is (single_eos)
      call this%assign_base_eos_param(other)
      if (allocated(other%mbwr_meos)) then
        istat = 0
        if (allocated(this%mbwr_meos)) deallocate(this%mbwr_meos, stat=istat)
        if (istat /= 0) call stoperror("Not able to deallocate this%mbwr_meos")
        allocate(this%mbwr_meos(size(other%mbwr_meos)), stat=istat)
        if (istat /= 0) call stoperror("Not able to allocate this%mbwr_meos")
        do i=1,size(other%mbwr_meos)
          this%mbwr_meos(i) = other%mbwr_meos(i)
        enddo
      endif
      if (allocated(other%nist)) then
        istat = 0
        if (allocated(this%nist)) deallocate(this%nist, stat=istat)
        if (istat /= 0) call stoperror("Not able to deallocate this%nist")
        allocate(this%nist(size(other%nist)), stat=istat)
        if (istat /= 0) call stoperror("Not able to allocate this%nist")
        do i=1,size(other%nist)
          if (associated(other%nist(i)%meos)) then
            istat = 0
            select type (p_meos => other%nist(i)%meos)
            class is (meos_c3)
              allocate(meos_c3 :: this%nist(i)%meos, stat=istat)
            class is (meos_normal_h2)
              allocate(meos_normal_h2 :: this%nist(i)%meos, stat=istat)
            class is (meos_ortho_h2)
              allocate(meos_ortho_h2 :: this%nist(i)%meos, stat=istat)
            class is (meos_para_h2)
              allocate(meos_para_h2 :: this%nist(i)%meos, stat=istat)
            class is (meos_r134a)
              allocate(meos_r134a :: this%nist(i)%meos, stat=istat)
            class default
              call stoperror("Only possible to use NIST MEOS with components: C3 or N/O/P-H2, or R134A")
            end select
            if (istat /= 0) call stoperror("Not able to allocate this%nist(i)%meos")
            this%nist(i)%meos = other%nist(i)%meos
          endif
        enddo
      endif
    class default
      print *,"assign_single_eos_set: Should not be here"
    end select
  end subroutine assign_single_eos_set

end module eos_parameters
