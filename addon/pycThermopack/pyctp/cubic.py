# Support for python2
from __future__ import print_function
# Import ctypes
from ctypes import *
# Importing Numpy (math, arrays, etc...)
import numpy as np
# Import platform to detect OS
from sys import platform, exit
# Import os utils
from os import path
# Import thermo
from . import thermo

c_len_type = thermo.c_len_type

class cubic(thermo.thermopack):
    """
    Interface to cubic
    """
    def __init__(self):
        """
        Initialize cubic specific function pointers
        """
        # Load dll/so
        super(cubic, self).__init__()

        # Init methods
        self.eoslibinit_init_cubic = getattr(self.tp, self.get_export_name("eoslibinit", "init_cubic"))
        # Tuning methods
        self.s_get_kij = getattr(self.tp, self.get_export_name("", "thermopack_getkij"))
        self.s_set_kij = getattr(self.tp, self.get_export_name("", "thermopack_setkijandji"))

        self.s_get_hv_param = getattr(self.tp, self.get_export_name("", "thermopack_gethvparam"))
        self.s_set_hv_param = getattr(self.tp, self.get_export_name("", "thermopack_sethvparam"))

        self.s_get_ci = getattr(self.tp, self.get_export_name("", "thermopack_get_volume_shift_parameter"))
        self.s_set_ci = getattr(self.tp, self.get_export_name("", "thermopack_set_volume_shift_parameter"))


    #################################
    # Init
    #################################

    def init(self, comps, eos, mixing="vdW", alpha="Classic",
             parameter_reference="Default", volume_shift=False):
        """Initialize cubic model in thermopack

        Args:
            comps (str): Comma separated list of component names
            eos (str): Equation of state (SRK, PR, ...)
            mixing (str, optional): Mixture model. Defaults to "vdW".
            alpha (str, optional): Alpha model. Defaults to "Classic".
            parameter_reference (str, optional): Which parameters to use?. Defaults to "Default".
        """
        eos_c = c_char_p(eos.encode('ascii'))
        eos_len = c_len_type(len(eos))
        mixing_c = c_char_p(mixing.encode('ascii'))
        mixing_len = c_len_type(len(mixing))
        alpha_c = c_char_p(alpha.encode('ascii'))
        alpha_len = c_len_type(len(alpha))
        comp_string_c = c_char_p(comps.encode('ascii'))
        comp_string_len = c_len_type(len(comps))
        ref_string_c = c_char_p(parameter_reference.encode('ascii'))
        ref_string_len = c_len_type(len(parameter_reference))

        if volume_shift:
            vol_shift_c = c_int(1)
        else:
            vol_shift_c = c_int(0)

        self.eoslibinit_init_cubic.argtypes = [c_char_p,
                                               c_char_p,
                                               c_char_p,
                                               c_char_p,
                                               c_char_p,
                                               POINTER (c_int),
                                               c_len_type,
                                               c_len_type,
                                               c_len_type,
                                               c_len_type,
                                               c_len_type]

        self.eoslibinit_init_cubic.restype = None

        self.eoslibinit_init_cubic(comp_string_c,
                                   eos_c,
                                   mixing_c,
                                   alpha_c,
                                   ref_string_c,
                                   byref(vol_shift_c),
                                   comp_string_len,
                                   eos_len,
                                   mixing_len,
                                   alpha_len,
                                   ref_string_len)
        self.nc = max(len(comps.split(" ")),len(comps.split(",")))

    def get_kij(self, c1, c2):
        """Get attractive energy interaction parameter

        Args:
            c1 (int): Component one
            c2 (int): Component two

        Returns:
            kij (float): i-j interaction parameter
        """
        c1_c = c_int(c1)
        c2_c = c_int(c2)
        kij_c = c_double(0.0)
        self.s_get_kij.argtypes = [POINTER(c_int),
                                   POINTER(c_int),
                                   POINTER(c_double)]

        self.s_get_kij.restype = None

        self.s_get_kij(byref(c1_c),
                       byref(c2_c),
                       byref(kij_c))

        return kij_c.value

    def set_kij(self, c1, c2, kij):
        """Set attractive energy interaction parameter

        Args:
            c1 (int): Component one
            c2 (int): Component two
            kij (float): i-j interaction parameter
        """
        c1_c = c_int(c1)
        c2_c = c_int(c2)
        kij_c = c_double(kij)
        self.s_set_kij.argtypes = [POINTER(c_int),
                                   POINTER(c_int),
                                   POINTER(c_double)]

        self.s_set_kij.restype = None

        self.s_set_kij(byref(c1_c),
                       byref(c2_c),
                       byref(kij_c))


    def get_lij(self, c1, c2):
        """Get co-volume interaction

        Args:
            c1 (int): Component one
            c2 (int): Component two

        Returns:
            lij (float): i-j interaction parameter
        """
        return 1.0

    def set_lij(self, c1, c2, lij):
        """Set co-volume interaction

        Args:
            c1 (int): Component one
            c2 (int): Component two
            lij ([type]): [description]
        """
        print("Setting lij")

    def get_hv_param(self, c1, c2):
        """Get Huron-Vidal parameters

        Args:
            c1 (int): Component one
            c2 (int): Component two

        Returns:
            alpha_ij (float): alpha param i-j
            alpha_ji (float): alpha param j-i
            a_ij (float): a param i-j
            a_ji (float): a param j-i
            b_ij (float): b param i-j
            b_ji (float): b param j-i
            c_ij (float): c param i-j
            c_ji (float): c param j-i
        """
        c1_c = c_int(c1)
        c2_c = c_int(c2)
        alpha_ij_c = c_double(0.0)
        alpha_ji_c = c_double(0.0)
        a_ij_c = c_double(0.0)
        a_ji_c = c_double(0.0)
        b_ij_c = c_double(0.0)
        b_ji_c = c_double(0.0)
        c_ij_c = c_double(0.0)
        c_ji_c = c_double(0.0)

        self.s_get_hv_param.argtypes = [POINTER(c_int),
                                        POINTER(c_int),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double)]

        self.s_get_hv_param.restype = None

        self.s_get_hv_param(byref(c1_c),
                            byref(c2_c),
                            byref(alpha_ij_c),
                            byref(alpha_ji_c),
                            byref(a_ij_c),
                            byref(a_ji_c),
                            byref(b_ij_c),
                            byref(b_ji_c),
                            byref(c_ij_c),
                            byref(c_ji_c))
        return alpha_ij_c.value, alpha_ji_c.value, a_ij_c.value, a_ji_c.value, b_ij_c.value, b_ji_c.value, c_ij_c.value, c_ji_c.value

    def set_hv_param(self, c1, c2, alpha_ij, alpha_ji, a_ij, a_ji, b_ij, b_ji, c_ij, c_ji):
        """Set Huron-Vidal parameters

        Args:
            c1 (int): Component one
            c2 (int): Component two
            alpha_ij (float): alpha param i-j
            alpha_ji (float): alpha param j-i
            a_ij (float): a param i-j
            a_ji (float): a param j-i
            b_ij (float): b param i-j
            b_ji (float): b param j-i
            c_ij (float): c param i-j
            c_ji (float): c param j-i
        """
        c1_c = c_int(c1)
        c2_c = c_int(c2)
        alpha_ij_c = c_double(alpha_ij)
        alpha_ji_c = c_double(alpha_ji)
        a_ij_c = c_double(a_ij)
        a_ji_c = c_double(a_ji)
        b_ij_c = c_double(b_ij)
        b_ji_c = c_double(b_ji)
        c_ij_c = c_double(c_ij)
        c_ji_c = c_double(c_ji)

        self.s_set_hv_param.argtypes = [POINTER(c_int),
                                        POINTER(c_int),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double),
                                        POINTER(c_double)]

        self.s_set_hv_param.restype = None

        self.s_set_hv_param(byref(c1_c),
                            byref(c2_c),
                            byref(alpha_ij_c),
                            byref(alpha_ji_c),
                            byref(a_ij_c),
                            byref(a_ji_c),
                            byref(b_ij_c),
                            byref(b_ji_c),
                            byref(c_ij_c),
                            byref(c_ji_c))

    def get_ci(self, cidx):
        """Get volume correction

        Args:
            cidx (int): Component index

        Returns:
            ci (float): Volume shift of component cidx (m3/mol)
        """
        cidx_c = c_int(cidx)
        ci_c = c_double(0.0)
        self.s_get_ci.argtypes = [POINTER(c_int),
                                  POINTER(c_double)]

        self.s_get_ci.restype = None

        self.s_get_ci(byref(cidx_c),
                      byref(ci_c))

        return ci_c.value

    def set_ci(self, cidx, ci):
        """Set volume correction

        Args:
            cidx (int): Component index
            ci (float): Volume shift of component cidx (m3/mol)
        """
        cidx_c = c_int(cidx)
        ci_c = c_double(ci)
        self.s_set_ci.argtypes = [POINTER(c_int),
                                  POINTER(c_double)]

        self.s_set_ci.restype = None

        self.s_set_ci(byref(cidx_c),
                      byref(ci_c))

