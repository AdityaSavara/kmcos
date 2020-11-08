module nli_0023
use kind_values
use lattice
use proclist_constants
implicit none
contains
pure function nli_m_COdes_b2(cell)
    integer(kind=iint), dimension(4), intent(in) :: cell
    integer(kind=iint) :: nli_m_COdes_b2

    select case(get_species(cell + (/0, 0, 0, Pd100_b2/)))
      case default
        nli_m_COdes_b2 = 0; return
      case(CO)
        nli_m_COdes_b2 = m_COdes_b2; return
    end select

end function nli_m_COdes_b2

end module
